import pandas as pd
import numpy as np
from matplotlib import pyplot as plt

df = pd.read_json('Data/Exp01_AC.json')
# df = pd.read_json('Data/Exp01_20220713_PC.json')
# df = pd.read_json('Data/Exp01_20220713_ST.json')

# err = df['click1_xloc'] - df['probe_xloc']
# bins = np.arange(-6, 6, .5)
# alpha = .8
# plt.hist(err[df['cnd'] == 'single1'], bins=bins, alpha=alpha, label='single1',
#          color='DodgerBlue')
# plt.hist(err[df['cnd'] == 'single2'], bins=bins, alpha=alpha, label='single2',
#          color='tomato')
# plt.legend()
# plt.show()

# msk = df['cnd'] == 'double'
# clk1 = df.loc[msk, 'click1_xloc']
# clk2 = df.loc[msk, 'click2_xloc']
# click_dist = abs(clk1 - clk2)
# bins = np.arange(0, 6, .25)
# alpha = .8
# plt.hist(click_dist, bins=bins, alpha=alpha, label='double', color='black')
# plt.show()