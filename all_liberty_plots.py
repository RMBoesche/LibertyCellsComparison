import re
import matplotlib.pyplot as plt
import numpy as np
import os

# Predefined indices
indices = {
    'input_transition_time': ['0.001000', '0.0078125', '0.015625', '0.031250', '0.062500', '0.125000', '0.250000'],
    'load_capacitance': ['0.001000', '0.0078125', '0.015625', '0.031250', '0.062500', '0.125000', '0.250000'],
    'data_transition_time': ['0.001000', '0.125000', '0.250000', '0.500000'],
    'clock_transition_time': ['0.001000', '0.062500', '0.125000', '0.250000']
}

# Mapping LUTs to their respective indices
lut_to_indices = {
    'fall_power': ('input_transition_time', 'load_capacitance'),
    'rise_power': ('input_transition_time', 'load_capacitance'),
    'cell_fall': ('input_transition_time', 'load_capacitance'),
    'cell_rise': ('input_transition_time', 'load_capacitance'),
    'fall_transition': ('input_transition_time', 'load_capacitance'),
    'rise_transition': ('input_transition_time', 'load_capacitance'),
}

def read_all_liberty_files(directory):
    all_lut_info = {}
    for filename in os.listdir(directory):
        if filename.endswith('.lib'):
            file_path = os.path.join(directory, filename)
            print(f"Processing file: {filename}")
            all_lut_info[filename] = parse_specific_luts(file_path)
    return all_lut_info

def parse_specific_luts(liberty_file_path):
    with open(liberty_file_path, 'r') as file:
        liberty_content = file.read()

    def extract_cell_content(liberty_text, cell_name):
        pattern = re.compile(r'cell\s*\(\s*' + re.escape(cell_name) + r'\s*\)\s*\{')
        match = pattern.search(liberty_text)
        if match:
            start_index = match.end()
            brace_count = 1
            end_index = start_index
            while brace_count > 0 and end_index < len(liberty_text):
                if liberty_text[end_index] == '{':
                    brace_count += 1
                elif liberty_text[end_index] == '}':
                    brace_count -= 1
                end_index += 1
            return liberty_text[start_index:end_index-1]
        return None

    def extract_lut_data(lut_content):
        values_pattern = re.compile(r'values\s*\(\s*(.*?)\s*\)', re.DOTALL)
        values_match = values_pattern.search(lut_content)
        
        if values_match:
            values_str = values_match.group(1).replace('\", \\', '').replace('"', '').strip()
            values = [val.strip().split(',') for val in values_str.split('\n') if val.strip()]
            return values
        return None

    cells = ['C2MOS_FF', 'TSPC_FF', 'TG_FF']
    all_cells_data = {}

    for cell_name in cells:
        cell_content = extract_cell_content(liberty_content, cell_name)
        
        if not cell_content:
            print(f"Cell content not found for {cell_name}.")
            continue

        lut_patterns = {
            'fall_power': re.compile(r'fall_power\s*\((?!Hidden_power).*?\)\s*\{(.*?)\}', re.DOTALL),
            'rise_power': re.compile(r'rise_power\s*\((?!Hidden_power).*?\)\s*\{(.*?)\}', re.DOTALL),
            'cell_fall': re.compile(r'cell_fall\s*\((?!Hidden_power).*?\)\s*\{(.*?)\}', re.DOTALL),
            'cell_rise': re.compile(r'cell_rise\s*\((?!Hidden_power).*?\)\s*\{(.*?)\}', re.DOTALL),
            'fall_transition': re.compile(r'fall_transition\s*\((?!Hidden_power).*?\)\s*\{(.*?)\}', re.DOTALL),
            'rise_transition': re.compile(r'rise_transition\s*\((?!Hidden_power).*?\)\s*\{(.*?)\}', re.DOTALL),
        }

        lut_data = {}
        for key, pattern in lut_patterns.items():
            matches = pattern.findall(cell_content)
            if matches:
                extracted_luts = []
                index_1, index_2 = lut_to_indices[key]
                for m in matches:
                    lut_values = extract_lut_data(m)
                    if lut_values:
                        extracted_luts.append({
                            'index_1': indices[index_1],
                            'index_2': indices[index_2],
                            'values': lut_values
                        })
                lut_data[key] = extracted_luts
        all_cells_data[cell_name] = lut_data

    return all_cells_data

def calculate_lut_averages(all_lut_info):
    vt_luts = {cell: {key: {'RVT': {'FF': [], 'TT': [], 'SS': []}, 'LVT': {'FF': [], 'TT': [], 'SS': []}, 'SLVT': {'FF': [], 'TT': [], 'SS': []}} for key in lut_to_indices.keys()} for cell in ['C2MOS_FF', 'TSPC_FF', 'TG_FF']}

    for file_name, cells in all_lut_info.items():
        vt = file_name.split('_')[0]
        corner = file_name.split('_')[-1].replace('.lib', '')
        for cell, luts in cells.items():
            for key, lut_list in luts.items():
                for lut in lut_list:
                    lut_values = np.array(lut['values'], dtype=float)
                    average_value = np.mean(lut_values)
                    if not np.isnan(average_value):
                        vt_luts[cell][key][vt][corner].append(average_value)

    final_averages = {}
    for cell, metrics in vt_luts.items():
        final_averages[cell] = {}
        for key, vts in metrics.items():
            final_averages[cell][key] = {}
            for vt, corners in vts.items():
                final_averages[cell][key][vt] = {}
                for corner, values in corners.items():
                    if values:
                        final_averages[cell][key][vt][corner] = np.mean(values)
                    else:
                        final_averages[cell][key][vt][corner] = float('nan')

    return final_averages

def plot_averages_for_vts(average_data):
    x_labels = ['RVT_FF', 'RVT_TT', 'RVT_SS', 'LVT_FF', 'LVT_TT', 'LVT_SS', 'SLVT_FF', 'SLVT_TT', 'SLVT_SS']
    vt_labels = ['RVT', 'LVT', 'SLVT']
    markers = {'C2MOS_FF': 'o', 'TSPC_FF': 's', 'TG_FF': '^'}  # 'o' for circle, 's' for square, '^' for triangle

    for key in lut_to_indices.keys():
        plt.figure(figsize=(12, 8))

        for cell_name, luts in average_data.items():
            y_values = []
            for vt in vt_labels:
                for corner in ['FF', 'TT', 'SS']:
                    if key in luts and vt in luts[key] and corner in luts[key][vt]:
                        y_values.append(luts[key][vt][corner])
                    else:
                        y_values.append(float('nan'))
            
            # Insert np.nan to break the line between different VTs
            y_values_with_nan = []
            x_labels_with_nan = []
            for i, y in enumerate(y_values):
                if i % 3 == 0 and i != 0:  # Add np.nan before starting a new VT section
                    y_values_with_nan.append(np.nan)
                    x_labels_with_nan.append('')
                y_values_with_nan.append(y)
                x_labels_with_nan.append(x_labels[i])

            marker = markers.get(cell_name, 'o')  # Default to circle if marker not found
            plt.plot(x_labels_with_nan, y_values_with_nan, marker=marker, label=cell_name)

        plt.xlabel('VT_Corner')
        plt.ylabel(key.replace('_', ' ').title())
        plt.title(f'{key.replace("_", " ").title()} Averages for VTs and Corners')
        plt.legend()
        plt.grid(True)
        plt.xticks(rotation=45)
        plt.savefig(f'{key}_VT_Corner_averages.png')
        plt.close()


liberty_directory = './liberty/'

all_lut_info = read_all_liberty_files(liberty_directory)

average_data = calculate_lut_averages(all_lut_info)

plot_averages_for_vts(average_data)

