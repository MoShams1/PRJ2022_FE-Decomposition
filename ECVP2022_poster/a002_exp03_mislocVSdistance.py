import pandas as pd
from matplotlib import pyplot as plt

df = pd.read_json('Data/Exp03_20220711_MS.json')

dist = df['probe_xloc'] - df['frame_flashxloc']
click_err = df['click1_xloc'] - df['probe_xloc']

msk75 = df['frame_size'] == 7.5
msk50 = df['frame_size'] == 5
msk05 = df['frame_size'] == .5

alpha = .8
plt.style.use('seaborn')
plt.scatter(dist[msk75]-7.5/2, click_err[msk75], c='black', alpha=alpha,
            label='fr_width: 7.5 deg')
plt.scatter(dist[msk50]-5.0/2, click_err[msk50], c='tomato', alpha=alpha,
            label='fr_width: 5 deg')
plt.scatter(dist[msk05]-0.5/2, click_err[msk05], c='dodgerblue', alpha=alpha,
            label='fr_width: 0.5 deg')
plt.xlabel("probe's distance to frame's front edge [dva]")
plt.ylabel("mislocalizatoin\n in the direction of frame's motion [dva]")
plt.legend()
plt.show()
