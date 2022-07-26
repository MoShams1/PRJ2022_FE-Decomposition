

import pandas as pd
import numpy as np
import os
from matplotlib import pyplot as plt

import supplements


def find_target_files(path_name, exp_name):
    all_files = os.listdir(path_name)
    return [f for f in all_files if exp_name in f]


path = 'Data/CleanData'
exp = 'Exp01'
files = find_target_files(path, exp)
num_sub = 5

# decide to plot the results with or without normalization
normalize = False

plt.style.use('seaborn')
supplements.init_figure()

all_double = np.full((num_sub, 1), np.nan)
all_single2 = np.full((num_sub, 1), np.nan)

for i, file in enumerate(files):

    df = pd.read_json(os.path.join(path, file))

    # filter out the leftward motions
    msk_left = df['frame_dir'] == 'left'

    # click distance between two flashes
    msk_double = df['cnd'] == 'double'
    click1 = df.loc[msk_double, 'click1_xloc']
    click2 = df.loc[msk_double, 'click2_xloc']
    dist_double = abs(click1 - click2)

    # single2: click error of the first and only flash
    msk_single = (df['cnd'] == 'single2')
    click = df.loc[msk_single, 'click1_xloc']
    probe = df.loc[msk_single, 'probe_xloc']
    dist_single2 = (click - probe)
    # flip the sign of click errors in the leftward motion
    dist_single2[msk_left] = -dist_single2
    dist_single2 = abs(dist_single2)

    if normalize:
        # normalize the errors within each subject
        errors = pd.concat([dist_double, dist_single2])
        dist_double = dist_double / errors.mean()
        dist_single2 = dist_single2 / errors.mean()

    all_double[i] = dist_double.mean()
    all_single2[i] = dist_single2.mean()

# plot across subject figures

fig, axs = plt.subplots(figsize=(7, 5))
y = [1, 2]
data = np.hstack([all_double, all_single2])
x = np.mean(data, axis=0)
xerr = np.std(data, axis=0) / (num_sub ** 0.5)
axs.barh(y, x, xerr=xerr)
axs.set_xlim(left=0, right=5)
axs.set_yticks(y)
axs.set_yticklabels(['Double', 'Single'])
axs.set_xlabel('Absolute perception error [dva]')
axs.set_title(f"N = {num_sub}")

fig.tight_layout()
# plt.show()
script_name = os.path.basename(__file__)[:7]
fig.savefig(f"Results/{script_name}_{exp}_perceptionErr.pdf")
