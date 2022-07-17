import pandas as pd
from matplotlib import pyplot as plt
import os


def find_target_files(path_name, exp_name):
    all_files = os.listdir(path_name)
    return [f for f in all_files if exp_name in f]


path = 'Data/CleanData'
exp = 'Exp03'
files = find_target_files(path, exp)

num_sub = 4

alpha = .8
plt.style.use('seaborn')
fig, axs = plt.subplots(1, num_sub, figsize=(20, 5), sharey=True)

for i, file in enumerate(files):
    df = pd.read_json(os.path.join(path, file))

    dist = df['probe_xloc'] - df['frame_flashxloc']
    click_err = df['click1_xloc'] - df['probe_xloc']

    msk75 = df['frame_size'] == 7.5
    msk50 = df['frame_size'] == 5
    msk05 = df['frame_size'] == .5

    axs[i].scatter(dist[msk75], click_err[msk75], c='black', alpha=alpha,
                   label='fr width: 7.5 deg')
    axs[i].scatter(dist[msk50], click_err[msk50], c='tomato', alpha=alpha,
                   label='fr width: 5 deg')
    axs[i].scatter(dist[msk05], click_err[msk05], c='dodgerblue', alpha=alpha,
                   label='fr width: 0.5 deg')

    axs[i].set_xlabel("probe's distance to frame's center [dva]")
    axs[i].set_title(f"subj:{i+1}")

axs[0].set_ylabel("absolute mislocalization\n in the direction of frame's "
                  "motion "
                  "[dva]")
axs[0].legend()
plt.show()
