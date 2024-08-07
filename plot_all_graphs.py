import re
import matplotlib.pyplot as plt
import numpy as np
import os

cells_names = ['PowerPC',
               'mC2MOS',
               'mC2MOS_ASAP7',
               'C2MOS',
               'TGFF',
               'TSPC',
               'TSPC_M1',
               'TGFF_DYN',
               ]

dyn_cells = ['TSPC',
             'TSPC_M1',
             'TGFF_DYN',]

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
    'hold_rising_fall': ('clock_transition_time', 'data_transition_time'),
    'hold_rising_rise': ('clock_transition_time', 'data_transition_time'),
    'setup_rising_fall': ('clock_transition_time', 'data_transition_time'),
    'setup_rising_rise': ('clock_transition_time', 'data_transition_time')
}

markers = {'mC2MOS': 'o',
           'mC2MOS_ASAP7': 'h',
           'PowerPC': '^',
           'C2MOS': '*',
           'TGFF': 'x',
           'TSPC': 's',
           'TSPC_M1': 'd',
           'TGFF_DYN': 'p',
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

    def extract_leakage_power(cell_content):
        pattern = re.compile(r'leakage_power\s*\(.*?\)\s*\{\s*related_pg_pin\s*:\s*"VDD";\s*value\s*:\s*([\d\.]+);', re.DOTALL)
        return [float(value) for value in pattern.findall(cell_content)]

    all_cells_data = {}

    for cell_name in cells_names:
        cell_content = extract_cell_content(liberty_content, cell_name)
        
        if not cell_content:
            # print(f"Cell content not found for {cell_name}.")
            continue

        lut_patterns = {
            'fall_power': re.compile(r'fall_power\s*\((?!Hidden_power).*?\)\s*\{(.*?)\}', re.DOTALL),
            'rise_power': re.compile(r'rise_power\s*\((?!Hidden_power).*?\)\s*\{(.*?)\}', re.DOTALL),
            'cell_fall': re.compile(r'cell_fall\s*\((?!Hidden_power).*?\)\s*\{(.*?)\}', re.DOTALL),
            'cell_rise': re.compile(r'cell_rise\s*\((?!Hidden_power).*?\)\s*\{(.*?)\}', re.DOTALL),
            'fall_transition': re.compile(r'fall_transition\s*\((?!Hidden_power).*?\)\s*\{(.*?)\}', re.DOTALL),
            'rise_transition': re.compile(r'rise_transition\s*\((?!Hidden_power).*?\)\s*\{(.*?)\}', re.DOTALL),
            'hold_rising_fall': re.compile(r'fall_constraint\s*\(Hold_fall_rise_4_4\)\s*\{(.*?)\}', re.DOTALL),
            'hold_rising_rise': re.compile(r'rise_constraint\s*\(Hold_rise_rise_4_4\)\s*\{(.*?)\}', re.DOTALL),
            'setup_rising_fall': re.compile(r'fall_constraint\s*\(Setup_fall_rise_4_4\)\s*\{(.*?)\}', re.DOTALL),
            'setup_rising_rise': re.compile(r'rise_constraint\s*\(Setup_rise_rise_4_4\)\s*\{(.*?)\}', re.DOTALL)
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
        
        # Extract leakage power
        leakage_power_values = extract_leakage_power(cell_content)
        if leakage_power_values:
            lut_data['leakage_power'] = leakage_power_values
        
        all_cells_data[cell_name] = lut_data

    return all_cells_data

def calculate_lut_worst_values(all_lut_info):
    vt_luts = {cell: {key: {'RVT': {'FF': [], 'TT': [], 'SS': []}, 'LVT': {'FF': [], 'TT': [], 'SS': []}, 'SLVT': {'FF': [], 'TT': [], 'SS': []}} for key in list(lut_to_indices.keys()) + ['leakage_power']} for cell in cells_names}

    for file_name, cells in all_lut_info.items():
        vt = file_name.split('_')[0]
        corner = file_name.split('_')[-1].replace('.lib', '')
        for cell, luts in cells.items():
            for key, lut_list in luts.items():
                if key == 'leakage_power' and cell in dyn_cells:
                    continue
                if key == 'leakage_power':
                    if lut_list:
                        worst_value = np.max(lut_list)
                        if not np.isnan(worst_value):
                            vt_luts[cell][key][vt][corner].append(worst_value)
                else:
                    for lut in lut_list:
                        lut_values = np.array(lut['values'], dtype=float)
                        worst_value = np.max(lut_values)
                        if not np.isnan(worst_value):
                            vt_luts[cell][key][vt][corner].append(worst_value)

    final_worst_values = {}
    for cell, metrics in vt_luts.items():
        final_worst_values[cell] = {}
        for key, vts in metrics.items():
            final_worst_values[cell][key] = {}
            for vt, corners in vts.items():
                final_worst_values[cell][key][vt] = {}
                for corner, values in corners.items():
                    if values:
                        final_worst_values[cell][key][vt][corner] = np.max(values)
                    else:
                        final_worst_values[cell][key][vt][corner] = float('nan')

    return final_worst_values

def calculate_additional_metrics(worst_data):
    additional_metrics = [
        'propagation_delay',
        'output_transition',
        'hold_time',
        'setup_time',
        'full_cycle_power',
        'power_delay_product',
        'energy_delay_product',
        'metastability_window',
        'constrained_D_to_Q_delay',
    ]

    # Inicializa as novas métricas para evitar KeyError
    for cell_name, metrics in worst_data.items():
        for metric in additional_metrics:
            if metric not in metrics:
                metrics[metric] = {vt: {corner: float('nan') for corner in ['FF', 'TT', 'SS']} for vt in ['RVT', 'LVT', 'SLVT']}

    for cell_name, metrics in worst_data.items():
        for vt in ['RVT', 'LVT', 'SLVT']:
            for corner in ['FF', 'TT', 'SS']:
                try:
                    # TODO : Utilizar as luts originais para calulcar as metricas adicionais e então pegar o maior valor da lut resultante.
                    # Calculate additional metrics
                    metrics['propagation_delay'][vt][corner] = (metrics['cell_rise'][vt][corner] + metrics['cell_fall'][vt][corner]) / 2
                    metrics['output_transition'][vt][corner] = (metrics['rise_transition'][vt][corner] + metrics['fall_transition'][vt][corner]) / 2
                    metrics['hold_time'][vt][corner] = max(metrics['hold_rising_rise'][vt][corner], metrics['hold_rising_fall'][vt][corner])
                    metrics['setup_time'][vt][corner] = max(metrics['setup_rising_rise'][vt][corner], metrics['setup_rising_fall'][vt][corner])
                    metrics['full_cycle_power'][vt][corner] = metrics['fall_power'][vt][corner] + metrics['rise_power'][vt][corner]
                    metrics['power_delay_product'][vt][corner] = ((metrics['fall_power'][vt][corner] + metrics['rise_power'][vt][corner]) / 2) * ((metrics['cell_rise'][vt][corner] + metrics['cell_fall'][vt][corner]) / 2)
                    metrics['energy_delay_product'][vt][corner] = ((metrics['fall_power'][vt][corner] + metrics['rise_power'][vt][corner]) / 2) * ((metrics['cell_rise'][vt][corner] + metrics['cell_fall'][vt][corner]) / 2) ** 2
                    metrics['metastability_window'][vt][corner] = metrics['setup_time'][vt][corner] + metrics['hold_time'][vt][corner]
                    metrics['constrained_D_to_Q_delay'][vt][corner] = metrics['propagation_delay'][vt][corner] + metrics['setup_time'][vt][corner]
                except KeyError as e:
                    print(f"KeyError for {cell_name} at {vt}_{corner}: {e}")
                    continue
    return worst_data

def plot_worst_values_for_vts_subplots(worst_data):
    x_labels = ['FF', 'TT', 'SS']
    vt_labels = ['RVT', 'LVT', 'SLVT']

    # Dicionário para mapear métricas às suas unidades
    metric_units = {
        'fall_power': 'nW/GHz',
        'rise_power': 'nW/GHz',
        'cell_fall': 'ps',
        'cell_rise': 'ps',
        'fall_transition': 'ps',
        'rise_transition': 'ps',
        'hold_rising_fall': 'ps',
        'hold_rising_rise': 'ps',
        'setup_rising_fall': 'ps',
        'setup_rising_rise': 'ps',
        'leakage_power': 'pW',
        'propagation_delay': 'ps',
        'output_transition': 'ps',
        'hold_time': 'ps',
        'setup_time': 'ps',
        'full_cycle_power': 'nW/GHz',
        'power_delay_product': 'nW*ps/GHz',
        'energy_delay_product': 'nW*ps²/GHz',
        'metastability_window': 'ps',
        'constrained_D_to_Q_delay': 'ps',
    }

    additional_metrics = [
        'propagation_delay',
        'output_transition',
        'hold_time',
        'setup_time',
        'full_cycle_power',
        'power_delay_product',
        'energy_delay_product', 
        'metastability_window',
        'constrained_D_to_Q_delay',
    ]

    additional_metrics_dir = './additional_metrics_graphs/'
    if not os.path.exists(additional_metrics_dir):
        os.makedirs(additional_metrics_dir)

    for key in list(lut_to_indices.keys()) + ['leakage_power'] + additional_metrics:
        fig, axes = plt.subplots(1, 3, figsize=(18, 6), sharey=False)
        fig.suptitle(f'{key.replace("_", " ").title()} for VTs and Corners')

        for idx, vt in enumerate(vt_labels):
            ax = axes[idx]
            for cell_name, luts in worst_data.items():
                y_values = []
                for corner in x_labels:
                    if key in luts and vt in luts[key] and corner in luts[key][vt]:
                        y_values.append(luts[key][vt][corner] * 1000) # The lib is in uW, so we convert to nW
                    else:
                        y_values.append(float('nan'))
                
                marker = markers.get(cell_name, 'o')  # Default to circle if marker not found
                ax.plot(x_labels, y_values, marker=marker, label=cell_name)

            ax.set_title(vt)
            ax.set_xlabel('Corner')
            ax.set_ylabel(f'{key.replace("_", " ").title()} ({metric_units.get(key, "")})')
            ax.grid(True)
            if idx == 0:
                ax.legend()

        plt.tight_layout(rect=[0, 0.03, 1, 0.95])
        if key in additional_metrics or key == 'leakage_power':
            plt.savefig(f'{additional_metrics_dir}/{key}_VT_Corner_worst.png')
        else:
            plt.savefig(f'./VT_Corner_graphs/{key}_VT_Corner_worst.png')
        plt.close()


liberty_directory = './liberty/'

all_lut_info = read_all_liberty_files(liberty_directory)

worst_data = calculate_lut_worst_values(all_lut_info)

worst_data = calculate_additional_metrics(worst_data)

plot_worst_values_for_vts_subplots(worst_data)

