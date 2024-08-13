import re
import matplotlib.pyplot as plt
import numpy as np
import os

additional_metrics = [
    'propagation_delay',
    'output_transition',
    'hold_time',
    'setup_time',
    'full_cycle_power',
    'metastability_window',
    'constrained_D_to_Q_delay',
    'energy_delay_product', 
    'area_energy_delay_product',
]

average_metric = {
    'fall_power',
    'rise_power',
    'cell_fall',
    'cell_rise',
    'output_fall_transition',
    'output_rise_transition',
}

worst_metric = {
    'hold_rising_fall',
    'hold_rising_rise',
    'setup_rising_fall',
    'setup_rising_rise'
}

# Dicionário para mapear métricas às suas unidades
metric_units = {
    'fall_power': 'µW/GHz',
    'rise_power': 'µW/GHz',
    'cell_fall': 'ps',
    'cell_rise': 'ps',
    'output_fall_transition': 'ps',
    'output_rise_transition': 'ps',
    'hold_rising_fall': 'ps',
    'hold_rising_rise': 'ps',
    'setup_rising_fall': 'ps',
    'setup_rising_rise': 'ps',
    'leakage_power': 'nW',
    'propagation_delay': 'ps',
    'output_transition': 'ps',
    'hold_time': 'ps',
    'setup_time': 'ps',
    'full_cycle_power': 'µW/GHz',
    'energy_delay_product': 'fJ*ps',
    'metastability_window': 'ps',
    'constrained_D_to_Q_delay': 'ps',
    'area_energy_delay_product': 'fJ*ps*µm²',
    'input_transition_time': 'ps',
    'load_capacitance': 'fF',
    'data_transition_time': 'ps', 
    'clock_transition_time': 'ps' 
}


flip_flops_area = {
    "TSPC": 0.145800,
    "TSPC_M1": 0.174960,
    "TGFF_DYN": 0.218700,
    "PowerPC": 0.262440,
    "mC2MOS": 0.262440,
    "mC2MOS_ASAP7": 0.291600,
    "C2MOS": 0.306180,
}


cells_names = ['PowerPC',
               'mC2MOS',
               'mC2MOS_ASAP7',
               'C2MOS',
               'TSPC',
               'TSPC_M1',
               'TGFF_DYN',
               ]

dyn_cells = ['TSPC',
             'TSPC_M1',
             'TGFF_DYN',]


indices = {
    'input_transition_time': ['1.0', '7.8125', '15.625', '31.25', '62.5', '125.0', '250.0'],
    'load_capacitance': ['0.1', '3.125', '6.25', '12.5', '25', '50', '100'],
    'data_transition_time': ['1.0', '125.0', '250.0', '500.0'],
    'clock_transition_time': ['1.0', '62.5', '125.0', '250.0']
}

# Mapping LUTs to their respective indices
lut_to_indices = {
    'fall_power': ('input_transition_time', 'load_capacitance'),
    'rise_power': ('input_transition_time', 'load_capacitance'),
    'cell_fall': ('input_transition_time', 'load_capacitance'),
    'cell_rise': ('input_transition_time', 'load_capacitance'),
    'output_fall_transition': ('input_transition_time', 'load_capacitance'),
    'output_rise_transition': ('input_transition_time', 'load_capacitance'),
    'hold_rising_fall': ('clock_transition_time', 'data_transition_time'),
    'hold_rising_rise': ('clock_transition_time', 'data_transition_time'),
    'setup_rising_fall': ('clock_transition_time', 'data_transition_time'),
    'setup_rising_rise': ('clock_transition_time', 'data_transition_time')
}

markers = {'mC2MOS': 'o',
           'mC2MOS_ASAP7': 'h',
           'PowerPC': '^',
           'C2MOS': '*',
           'TSPC': 's',
           'TSPC_M1': 'd',
           'TGFF_DYN': 'x',
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
            print(f"Cell content not found for {cell_name}.")
            continue

        lut_patterns = {
            'fall_power': re.compile(r'fall_power\s*\((?!Hidden_power).*?\)\s*\{(.*?)\}', re.DOTALL),
            'rise_power': re.compile(r'rise_power\s*\((?!Hidden_power).*?\)\s*\{(.*?)\}', re.DOTALL),
            'cell_fall': re.compile(r'cell_fall\s*\((?!Hidden_power).*?\)\s*\{(.*?)\}', re.DOTALL),
            'cell_rise': re.compile(r'cell_rise\s*\((?!Hidden_power).*?\)\s*\{(.*?)\}', re.DOTALL),
            'output_fall_transition': re.compile(r'fall_transition\s*\((?!Hidden_power).*?\)\s*\{(.*?)\}', re.DOTALL),
            'output_rise_transition': re.compile(r'rise_transition\s*\((?!Hidden_power).*?\)\s*\{(.*?)\}', re.DOTALL),
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

def calculate_lut_values(all_lut_info):
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
                        target_value = np.max(lut_list)
                        if not np.isnan(target_value):
                            vt_luts[cell][key][vt][corner].append(target_value/1000.0)
                else:
                    for lut in lut_list:
                        lut_values = np.array(lut['values'], dtype=float)
                        if key in average_metric:
                            if lut_values.shape != (1,1):
                                target_value = np.average(lut_values[:, 2])
                            else:
                                target_value = np.nan
                        elif key in worst_metric:
                            target_value = np.max(lut_values)
                        if not np.isnan(target_value):
                            vt_luts[cell][key][vt][corner].append(target_value)

    final_target_values = {}
    for cell, metrics in vt_luts.items():
        final_target_values[cell] = {}
        for key, vts in metrics.items():
            final_target_values[cell][key] = {}
            for vt, corners in vts.items():
                final_target_values[cell][key][vt] = {}
                for corner, values in corners.items():
                    if values:
                        final_target_values[cell][key][vt][corner] = np.max(values)
                    else:
                        final_target_values[cell][key][vt][corner] = float('nan')

    return final_target_values

def calculate_additional_metrics(all_lut_info, plot_data):
    def calculate_metric_from_lut(lut_1, lut_2, operation):
        combined_values = []
        for row1, row2 in zip(lut_1, lut_2):
            combined_row = []
            for v1, v2 in zip(row1, row2):
                if operation == 'add':
                    combined_row.append(float(v1) + float(v2))
                elif operation == 'max':
                    combined_row.append(max(float(v1), float(v2)))
                elif operation == 'avg':
                    combined_row.append((float(v1) + float(v2)) / 2.0)
            combined_values.append(combined_row)
        return np.array(combined_values)

    for file_name, cells in all_lut_info.items():
        vt = file_name.split('_')[0]
        corner = file_name.split('_')[-1].replace('.lib', '')
        for cell_name, luts in cells.items():
            try:
                lut_rise = np.array(luts['cell_rise'][0]['values'], dtype=float)
                lut_fall = np.array(luts['cell_fall'][0]['values'], dtype=float)
                lut_rise_column = lut_rise[:, 2]
                lut_fall_column = lut_fall[:, 2]
                average_rise_fall = (lut_rise_column + lut_fall_column) / 2.0
                propagation_delay = np.average(average_rise_fall)

                lut_rise_trans = np.array(luts['output_rise_transition'][0]['values'], dtype=float)
                lut_fall_trans = np.array(luts['output_fall_transition'][0]['values'], dtype=float)
                lut_rise_trans_column = lut_rise_trans[:, 2]
                lut_fall_trans_column = lut_fall_trans[:, 2]
                average_rise_fall_trans = (lut_rise_trans_column + lut_fall_trans_column) / 2.0
                output_transition = np.average(average_rise_fall_trans)

                lut_hold_rise = np.array(luts['hold_rising_rise'][0]['values'], dtype=float)
                lut_hold_fall = np.array(luts['hold_rising_fall'][0]['values'], dtype=float)
                hold_time = max(np.max(lut_hold_rise), np.max(lut_hold_fall))

                lut_setup_rise = np.array(luts['setup_rising_rise'][0]['values'], dtype=float)
                lut_setup_fall = np.array(luts['setup_rising_fall'][0]['values'], dtype=float)
                setup_time = max(np.max(lut_setup_rise), np.max(lut_setup_fall))

                # Calculate full cycle power
                lut_fall_power = np.array(luts['fall_power'][0]['values'], dtype=float) 
                lut_rise_power = np.array(luts['rise_power'][2]['values'], dtype=float)
                lut_fall_power_column = lut_fall_power[:, 2]
                lut_rise_power_column = lut_rise_power[:, 2]
                sum_fall_rise_power = lut_fall_power_column + lut_rise_power_column
                average_fall_rise_power = (lut_fall_power_column + lut_rise_power_column) / 2.0
                full_cycle_power = np.average(sum_fall_rise_power)

                propagation_power = np.average(average_fall_rise_power)

                # Inicializa a metastability_window com 0
                metastability_window = 0
                
                # Verifica as condições para soma
                if hold_time > 0 and setup_time > 0:
                    metastability_window = hold_time + setup_time
                elif hold_time > 0:
                    metastability_window = hold_time
                elif setup_time > 0:
                    metastability_window = setup_time

                max_setup_rise = np.max(lut_setup_rise)
                max_setup_fall = np.max(lut_setup_fall)
                max_rise = np.max(lut_rise_column)
                max_fall = np.max(lut_fall_column)
                constrained_D_to_Q_delay = max(max_setup_rise + max_rise, max_setup_fall + max_fall)

                energy_delay_product = propagation_power * propagation_delay
                area_energy_delay_product = flip_flops_area[cell_name] * energy_delay_product

                plot_data[cell_name].setdefault('propagation_delay', {}).setdefault(vt, {})[corner] = propagation_delay
                plot_data[cell_name].setdefault('output_transition', {}).setdefault(vt, {})[corner] = output_transition
                plot_data[cell_name].setdefault('hold_time', {}).setdefault(vt, {})[corner] = hold_time
                plot_data[cell_name].setdefault('setup_time', {}).setdefault(vt, {})[corner] = setup_time
                plot_data[cell_name].setdefault('full_cycle_power', {}).setdefault(vt, {})[corner] = full_cycle_power
                plot_data[cell_name].setdefault('metastability_window', {}).setdefault(vt, {})[corner] = metastability_window
                plot_data[cell_name].setdefault('constrained_D_to_Q_delay', {}).setdefault(vt, {})[corner] = constrained_D_to_Q_delay
                plot_data[cell_name].setdefault('energy_delay_product', {}).setdefault(vt, {})[corner] = energy_delay_product
                plot_data[cell_name].setdefault('area_energy_delay_product', {}).setdefault(vt, {})[corner] = area_energy_delay_product

            except KeyError as e:
                print(f"KeyError for {cell_name} at {vt}_{corner}: {e}")
                continue

    return plot_data

def plot_vts_subplots(plot_data):
    x_labels = ['SS', 'TT', 'FF']
    vt_labels = ['RVT', 'LVT', 'SLVT']

    metrics_dir = './plots/metrics_graphs/'
    if not os.path.exists(metrics_dir):
        os.makedirs(metrics_dir)

    for key in list(lut_to_indices.keys()) + ['leakage_power'] + additional_metrics:
        fig, axes = plt.subplots(1, 3, figsize=(18, 6), sharey=False)
        fig.suptitle(f'{key.replace("_", " ").title()} for VTs and Corners')

        for idx, vt in enumerate(vt_labels):
            ax = axes[idx]
            for cell_name, luts in plot_data.items():
                if key == 'metastability_window' and cell_name == 'TGFF_DYN':
                    continue
                y_values_list = []
                for corner in x_labels:
                    if key in luts and vt in luts[key] and corner in luts[key][vt]:
                        y_values_list.append(luts[key][vt][corner])
                    else:
                        y_values_list.append(float('nan'))
                
                marker = markers.get(cell_name, 'o')  # Default to circle if marker not found
                y_values = np.array(y_values_list, dtype=float)
                ax.plot(x_labels, y_values, marker=marker, label=cell_name)

            ax.set_title(vt)
            ax.set_xlabel('Corner')
            ax.set_ylabel(f'{key.replace("_", " ").title()} ({metric_units.get(key, "")})')
            ax.grid(True)
            if idx == 0:
                ax.legend()

        plt.tight_layout(rect=[0, 0.03, 1, 0.95])
        plt.savefig(f'{metrics_dir}/{key}_VT_Corner.png')
        plt.close()

def plot_individual_luts(all_lut_info):
    for file_name, cells in all_lut_info.items():
        for cell_name, lut_info in cells.items():
            for key, luts in lut_info.items():
                if key == 'leakage_power':
                    continue
                if cell_name != 'C2MOS':
                    continue
                if file_name != 'RVT_TT.lib':
                    continue

                file_name_path = file_name.split('.')[0]
                individual_graphs_dir = f'./plots/individual_graphs/{file_name_path}/{cell_name}/'
                if not os.path.exists(individual_graphs_dir):
                    os.makedirs(individual_graphs_dir)
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
                            plt.plot(index_1, row_values, label=f'{index_2_name} = {index_2[i]} {metric_units.get(index_2_label, "")}')
                        else:
                            print(f"Skipping plot for {key} in {cell_name} due to dimension mismatch: len(index_1)={len(index_1)} len(row_values)={len(row_values)} row_values={row_values}")
                
                # Ensure x-axis ticks are displayed
                plt.xticks(index_1, labels=[f'{x:.2f}' for x in index_1], rotation=45)
                plt.xlabel(index_1_name + f' ({metric_units.get(index_1_label, "")})')
                plt.ylabel(f'{key.replace("_", " ").title()} ({metric_units.get(key, "")})')
                plt.title(f'{cell_name} - {key.replace("_", " ").title()} vs {index_1_name}')
                plt.legend(title=index_2_name)
                plt.grid(True)
                plt.tight_layout()  # Adjust layout to ensure everything fits
                plt.savefig(f'{individual_graphs_dir}/{key}_{index_1_label}.png')  # Save the plot as a PNG file
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
                            plt.plot(index_2, col_values, label=f'{index_1_name} = {index_1[i]} {metric_units.get(index_1_label, "")}')
                        else:
                            print(f"Skipping plot for {key} in {cell_name} due to dimension mismatch: len(index_2)={len(index_2)} len(col_values)={len(col_values)} col_values={col_values}")
                
                # Ensure x-axis ticks are displayed
                plt.xticks(index_2, labels=[f'{x:.2f}' for x in index_2], rotation=45)
                plt.xlabel(index_2_name + f' ({metric_units.get(index_2_label, "")})')
                plt.ylabel(f'{key.replace("_", " ").title()} ({metric_units.get(key, "")})')
                plt.title(f'{cell_name} - {key.replace("_", " ").title()} vs {index_2_name}')
                plt.legend(title=index_1_name)
                plt.grid(True)
                plt.tight_layout()  # Adjust layout to ensure everything fits
                plt.savefig(f'{individual_graphs_dir}/{key}_{index_2_label}.png')  # Save the plot as a PNG file
                plt.close()


liberty_directory = './liberty/'

all_lut_info = read_all_liberty_files(liberty_directory)

plot_data = calculate_lut_values(all_lut_info)

plot_individual_luts(all_lut_info)

# plot_data = calculate_additional_metrics(all_lut_info, plot_data)

# plot_vts_subplots(plot_data)


