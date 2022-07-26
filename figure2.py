"""
Analyzing Exp. 01: mislocalization size as a measure of frame repetition (norm)

    fig. 1: comparing the the distribution of click errors in each
    individual in three frame motion repetition and in different conditons:
    double, single1, and single2.

    fig. 2: average click error in each of the three repetition condition,
    separated by each probe condition (double, single1, single2).
"""

import pandas as pd
import numpy as np
import os
from matplotlib import pyplot as plt
import supplements as sup


def find_target_files(path_name, exp_name):
    all_files = os.listdir(path_name)
    return [f for f in all_files if exp_name in f]


path = 'Data/CleanData'
exp = 'Exp01'
files = find_target_files(path, exp)

num_sub = 5

plt.style.use('seaborn')
sup.init_figure()

all_double = np.full((num_sub, 3), np.nan)
all_single1 = np.full((num_sub, 3), np.nan)
all_single2 = np.full((num_sub, 3), np.nan)

for i, file in enumerate(files):

    df = pd.read_json(os.path.join(path, file))

    # filter out the leftward motions
    msk_left = df['frame_dir'] == 'left'

    # click distance between two flashes
    msk_double = df['cnd'] == 'double'
    msk_n1 = df['frame_ncycles'] == 1
    click1 = df.loc[msk_double & msk_n1, 'click1_xloc']
    click2 = df.loc[msk_double & msk_n1, 'click2_xloc']
    dist_double_n1 = abs(click1 - click2)
    msk_n2 = df['frame_ncycles'] == 2
    click1 = df.loc[msk_double & msk_n2, 'click1_xloc']
    click2 = df.loc[msk_double & msk_n2, 'click2_xloc']
    dist_double_n2 = abs(click1 - click2)
    msk_n3 = df['frame_ncycles'] == 3
    click1 = df.loc[msk_double & msk_n3, 'click1_xloc']
    click2 = df.loc[msk_double & msk_n3, 'click2_xloc']
    dist_double_n3 = abs(click1 - click2)

    # click error of the first and only flash
    msk_single2 = df['cnd'] == 'single2'
    msk_n1 = df['frame_ncycles'] == 1
    click = df.loc[msk_single2 & msk_n1, 'click1_xloc']
    probe = df.loc[msk_single2 & msk_n1, 'probe_xloc']
    dist_single2_n1 = (click - probe)
    dist_single2_n1[msk_left] = -dist_single2_n1
    dist_single2_n1 = abs(dist_single2_n1)

    msk_n2 = df['frame_ncycles'] == 2
    click = df.loc[msk_single2 & msk_n2, 'click1_xloc']
    probe = df.loc[msk_single2 & msk_n2, 'probe_xloc']
    dist_single2_n2 = (click - probe)
    dist_single2_n2[msk_left] = -dist_single2_n2
    dist_single2_n2 = abs(dist_single2_n2)

    msk_n3 = df['frame_ncycles'] == 3
    click = df.loc[msk_single2 & msk_n3, 'click1_xloc']
    probe = df.loc[msk_single2 & msk_n3, 'probe_xloc']
    dist_single2_n3 = (click - probe)
    dist_single2_n3[msk_left] = -dist_single2_n3
    dist_single2_n3 = abs(dist_single2_n3)

    # normalize the errors within each subject
    errors = pd.concat([dist_double_n1, dist_double_n2, dist_double_n3,
                        dist_single2_n1, dist_single2_n2, dist_single2_n3])
    dist_double_n1 = dist_double_n1 / errors.mean()
    dist_double_n2 = dist_double_n2 / errors.mean()
    dist_double_n3 = dist_double_n3 / errors.mean()
    dist_single2_n1 = dist_single2_n1 / errors.mean()
    dist_single2_n2 = dist_single2_n2 / errors.mean()
    dist_single2_n3 = dist_single2_n3 / errors.mean()

    all_double[i, 0] = dist_double_n1.mean()
    all_double[i, 1] = dist_double_n2.mean()
    all_double[i, 2] = dist_double_n3.mean()
    all_single2[i, 0] = dist_single2_n1.mean()
    all_single2[i, 1] = dist_single2_n2.mean()
    all_single2[i, 2] = dist_single2_n3.mean()

# plot across subject figures
fig, axs = plt.subplots(figsize=(7, 6))
lw = 3

y = [1, 2, 3]
x = np.mean(all_double, axis=0)
xerr = np.std(all_double, axis=0) / (num_sub ** 0.5)
axs.errorbar(x, y, xerr=xerr, fmt='-o', color='black', label='double',
             linewidth=lw)

x = np.mean(all_single2, axis=0)
xerr = np.std(all_single2, axis=0) / (num_sub ** 0.5)
axs.errorbar(x, y, xerr=xerr, fmt='-o', color='dodgerblue', label='single2',
             linewidth=lw)

axs.set_xlabel("Absolute perception error\n(within subject normalized)")
axs.set_yticks(y)
axs.set_ylabel("# of frame cycles")
axs.set_title(f"N = {num_sub}")
# axs.legend()

plt.tight_layout()
# plt.show()
script_name = os.path.basename(__file__)[:7]
fig.savefig(f"Results/{script_name}_{exp}_repetition.pdf")
