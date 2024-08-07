import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

# Dados fornecidos
flip_flops = {
    "C2MOS_DYN": 145800,
    "C2MOS_DYN_M1": 160380,
    "TSPC": 145800,
    "TSPC_M1": 174960,
    "TGFF_DYN": 218700,
    "mC2MOS": 262440,
    "PowerPC": 262440,
    "mC2MOS_ASAP7": 291600,
}

# Converta os dados para um DataFrame
df = pd.DataFrame(list(flip_flops.items()), columns=["Flip Flop", "Area (nm²)"])

# Função para plotar o gráfico de barras
def plot_flip_flop_areas(dataframe, y_spacing):
    plt.figure(figsize=(10, 6))
    # Dividir os valores da área por 1000 para ter a escala em milhares de nanômetros quadrados (10³ nm²)
    dataframe["Area (10³ nm²)"] = dataframe["Area (nm²)"] / 1000
    plt.bar(dataframe["Flip Flop"], dataframe["Area (10³ nm²)"], color='skyblue')
    plt.xlabel('Flip Flop')
    plt.ylabel('Area (10³ nm²)')
    plt.title('Flip Flops Area Comparison')
    plt.yticks(np.arange(0, dataframe["Area (10³ nm²)"].max() + y_spacing, y_spacing))
    plt.grid(axis='y', linestyle='--', alpha=0.7)
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig('./area_plot/area_comparison.png')

# Plotar o gráfico com espaçamento de 145.8 (10³ nm²)
plot_flip_flop_areas(df, 14.58)

