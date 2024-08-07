import matplotlib.pyplot as plt
import pandas as pd

# Dados fornecidos
flip_flops = {
    "TSPC": 145800,
    "TSPC_M1": 174960,
    "TGFF_DYN": 218700,
    # "C2MOS_DYN": 145800,
    # "C2MOS_DYN_M1": 160380,
    "mC2MOS_ASAP7": 291600,
    "mC2MOS": 262440,
    "PowerPC": 262440
}

# Converta os dados para um DataFrame
df = pd.DataFrame(list(flip_flops.items()), columns=["Flip Flop", "Area (nm²)"])

# Função para plotar o gráfico de barras
def plot_flip_flop_areas(dataframe, y_spacing):
    plt.figure(figsize=(10, 6))
    plt.bar(dataframe["Flip Flop"], dataframe["Area (nm^2)"], color='skyblue')
    plt.xlabel('Flip Flop')
    plt.ylabel('Area (nm^2)')
    plt.title('Flip Flops Area Comparison')
    plt.yticks(range(0, int(dataframe["Area (nm^2)"].max()) + y_spacing, y_spacing))
    plt.grid(axis='y', linestyle='--', alpha=0.7)
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(f'./area_plot/area_comparison.png')

# Plotar o gráfico com espaçamento de 14580 nm^2
plot_flip_flop_areas(df, 14580)

