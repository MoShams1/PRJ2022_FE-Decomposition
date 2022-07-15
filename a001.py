import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
#
df = pd.read_json('Data/Exp01_20220711_MS.json')
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

msk1 = (df['cnd'] == 'double') & (df['frame_ncycles'] == 1)
msk2 = (df['cnd'] == 'double') & (df['frame_ncycles'] == 2)
msk3 = (df['cnd'] == 'double') & (df['frame_ncycles'] == 3)

clk1 = df.loc[msk1, 'click1_xloc']
clk2 = df.loc[msk1, 'click2_xloc']
click_dist_rep1 = abs(clk1 - clk2)
clk1 = df.loc[msk2, 'click1_xloc']
clk2 = df.loc[msk2, 'click2_xloc']
click_dist_rep2 = abs(clk1 - clk2)
clk1 = df.loc[msk3, 'click1_xloc']
clk2 = df.loc[msk3, 'click2_xloc']
click_dist_rep3 = abs(clk1 - clk2)
bins = np.arange(0, 6, .2)
alpha = .7
plt.hist(click_dist_rep1, bins=bins, alpha=alpha, label='double',
         color='black')
plt.hist(click_dist_rep2, bins=bins, alpha=alpha, label='double',
         color='tomato')
plt.hist(click_dist_rep3, bins=bins, alpha=alpha, label='double',
         color='dodgerblue')
plt.show()
