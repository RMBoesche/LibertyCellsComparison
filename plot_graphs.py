import re
import matplotlib.pyplot as plt

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

def parse_specific_luts(liberty_file_path):
    # Reading the content of the liberty file
    with open(liberty_file_path, 'r') as file:
        liberty_content = file.read()

    # Function to extract the content of a specific cell, considering nested braces
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

    # Function to extract LUT data
    def extract_lut_data(lut_content):
        values_pattern = re.compile(r'values\s*\(\s*(.*?)\s*\)', re.DOTALL)
        values_match = values_pattern.search(lut_content)
        
        if values_match:
            values_str = values_match.group(1).replace('\", \\', '').replace('"', '').strip()
            values = [val.strip().split(',') for val in values_str.split('\n') if val.strip()]
            return values
        return None

    # Extracting content for multiple cells
    cells = ['C2MOS_FF', 'TSPC_FF', 'TG_FF']
    all_cells_data = {}

    for cell_name in cells:
        cell_content = extract_cell_content(liberty_content, cell_name)
        
        if not cell_content:
            print(f"Cell content not found for {cell_name}.")
            continue
        
        # print(f"Extracted cell content for {cell_name}:\n{cell_content[:500]}...")  # Print first 500 characters for context

        # Extracting specific LUTs
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
                # print(f"Extracted LUT for {key} in cell {cell_name}: {lut_data[key]}")
            else:
                print(f"No LUT found for {key} in cell {cell_name}")
        
        all_cells_data[cell_name] = lut_data

    return all_cells_data

def plot_individual_luts(cell_name, lut_info):
    for key, luts in lut_info.items():
        if key not in ['rise_power', 'fall_power', 'cell_fall', 'cell_rise', 'fall_transition', 'rise_transition']:
            continue
        
        index_1_label, index_2_label = lut_to_indices[key]
        index_1_name = index_1_label.replace('_', ' ').title()
        index_2_name = index_2_label.replace('_', ' ').title()
        
        # Plotting index_1 vs values
        plt.figure(figsize=(10, 6))
        for lut in luts:
            index_1 = [float(x) for x in lut['index_1']]
            index_2 = [float(x) for x in lut['index_2']]
            values = lut['values']
            
            for i, row in enumerate(values):
                row_values = [float(v) for v in row]
                if len(index_1) == len(row_values):  # Ensure both lists have the same length
                    plt.plot(index_1, row_values, label=f'{index_2_name} = {index_2[i]}')
                else:
                    print(f"Skipping plot for {key} in {cell_name} due to dimension mismatch: len(index_1)={len(index_1)} len(row_values)={len(row_values)} row_values={row_values}")
        
        plt.xscale('log')
        plt.xlabel(index_1_name)
        plt.ylabel(key.replace('_', ' ').title())
        plt.title(f'{cell_name} - {key.replace("_", " ").title()} vs {index_1_name}')
        plt.legend(title=index_2_name)
        plt.grid(True)
        plt.savefig(f'./graphs/{cell_name}_{key}_{index_1_label}.png')  # Save the plot as a PNG file
        plt.close()

        # Plotting index_2 vs values
        plt.figure(figsize=(10, 6))
        for lut in luts:
            index_1 = [float(x) for x in lut['index_1']]
            index_2 = [float(x) for x in lut['index_2']]
            values = lut['values']
            
            for i, col in enumerate(zip(*values)):  # Transpose the rows to columns for index_2
                col_values = [float(v) for v in col]
                if len(index_2) == len(col_values):  # Ensure both lists have the same length
                    plt.plot(index_2, col_values, label=f'{index_1_name} = {index_1[i]}')
                else:
                    print(f"Skipping plot for {key} in {cell_name} due to dimension mismatch: len(index_2)={len(index_2)} len(col_values)={len(col_values)} col_values={col_values}")
        
        plt.xscale('log')
        plt.xlabel(index_2_name)
        plt.ylabel(key.replace('_', ' ').title())
        plt.title(f'{cell_name} - {key.replace("_", " ").title()} vs {index_2_name}')
        plt.legend(title=index_1_name)
        plt.grid(True)
        plt.savefig(f'./graphs/{cell_name}_{key}_{index_2_label}.png')  # Save the plot as a PNG file
        plt.close()

# Path to the Liberty file
liberty_file_path = './liberty/asap7sc7p5t_RVT_TypTyp_0p70_25_conditional_nldm.lib'

# Extracting LUT information for multiple cells
all_lut_info = parse_specific_luts(liberty_file_path)

# Plotting individual LUTs for each cell
for cell, lut_info in all_lut_info.items():
    plot_individual_luts(cell, lut_info)

