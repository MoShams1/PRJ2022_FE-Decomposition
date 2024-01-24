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


def find_target_files(path_name, exp_name):
    all_files = os.listdir(path_name)
    return [f for f in all_files if exp_name in f]


path = 'Data/CleanData'
exp = 'Exp01'
files = find_target_files(path, exp)

num_sub = 5

plt.style.use('seaborn')
fig1, axs1 = plt.subplots(nrows=3, ncols=num_sub, sharex=True,
                          figsize=(20, 10))
bins = np.arange(0, 10, .2)

all_double = np.full((num_sub, 3), np.nan)
all_single1 = np.full((num_sub, 3), np.nan)
all_single2 = np.full((num_sub, 3), np.nan)

for i, file in enumerate(files):
    df = pd.read_json(os.path.join(path, file))

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
    msk_single1 = df['cnd'] == 'single1'
    msk_n1 = df['frame_ncycles'] == 1
    click = df.loc[msk_single1 & msk_n1, 'click1_xloc']
    probe = df.loc[msk_single1, 'probe_xloc']
    dist_single1_n1 = abs(click - probe)
    msk_n2 = df['frame_ncycles'] == 2
    click = df.loc[msk_single1 & msk_n2, 'click1_xloc']
    probe = df.loc[msk_single1, 'probe_xloc']
    dist_single1_n2 = abs(click - probe)
    msk_n3 = df['frame_ncycles'] == 3
    click = df.loc[msk_single1 & msk_n3, 'click1_xloc']
    probe = df.loc[msk_single1, 'probe_xloc']
    dist_single1_n3 = abs(click - probe)
    # click error of the first and only flash
    msk_single2 = df['cnd'] == 'single2'
    msk_n1 = df['frame_ncycles'] == 1
    click = df.loc[msk_single2 & msk_n1, 'click1_xloc']
    probe = df.loc[msk_single2, 'probe_xloc']
    dist_single2_n1 = abs(click - probe)
    msk_n2 = df['frame_ncycles'] == 2
    click = df.loc[msk_single2 & msk_n2, 'click1_xloc']
    probe = df.loc[msk_single2, 'probe_xloc']
    dist_single2_n2 = abs(click - probe)
    msk_n3 = df['frame_ncycles'] == 3
    click = df.loc[msk_single2 & msk_n3, 'click1_xloc']
    probe = df.loc[msk_single2, 'probe_xloc']
    dist_single2_n3 = abs(click - probe)

    # normalize the errors within each subject
    errors = pd.concat([dist_double_n1, dist_double_n2, dist_double_n3,
                        dist_single1_n1, dist_single1_n2, dist_single1_n3,
                        dist_single2_n1, dist_single2_n2, dist_single2_n3])
    dist_double_n1 = dist_double_n1 / errors.mean()
    dist_single1_n1 = dist_single1_n1 / errors.mean()
    dist_single2_n1 = dist_single2_n1 / errors.mean()
    dist_double_n2 = dist_double_n2 / errors.mean()
    dist_single1_n2 = dist_single1_n2 / errors.mean()
    dist_single2_n2 = dist_single2_n2 / errors.mean()
    dist_double_n3 = dist_double_n3 / errors.mean()
    dist_single1_n3 = dist_single1_n3 / errors.mean()
    dist_single2_n3 = dist_single2_n3 / errors.mean()

    axs1[0, i].hist(dist_double_n1, bins=bins)
    axs1[0, i].hist(dist_double_n2, bins=bins)
    axs1[0, i].hist(dist_double_n3, bins=bins)
    axs1[0, i].set_title(f"double-subj#{i + 1}")
    axs1[0, i].set_ylabel('count')
    axs1[1, i].hist(dist_single1_n1, bins=bins)
    axs1[1, i].hist(dist_single1_n2, bins=bins)
    axs1[1, i].hist(dist_single1_n3, bins=bins)
    axs1[1, i].set_title(f"single1-subj#{i + 1}")
    axs1[1, i].set_ylabel('count')
    axs1[2, i].hist(dist_single2_n1, bins=bins)
    axs1[2, i].hist(dist_single2_n2, bins=bins)
    axs1[2, i].hist(dist_single2_n3, bins=bins)
    axs1[2, i].set_title(f"single2-subj#{i + 1}")
    axs1[2, i].set_xlabel('absolute localization error [dva]')
    axs1[2, i].set_ylabel('count')

    all_double[i, 0] = dist_double_n1.mean()
    all_double[i, 1] = dist_double_n2.mean()
    all_double[i, 2] = dist_double_n3.mean()
    all_single1[i, 0] = dist_single1_n1.mean()
    all_single1[i, 1] = dist_single1_n2.mean()
    all_single1[i, 2] = dist_single1_n3.mean()
    all_single2[i, 0] = dist_single2_n1.mean()
    all_single2[i, 1] = dist_single2_n2.mean()
    all_single2[i, 2] = dist_single2_n3.mean()

# plot across subject figures
fig2, axs2 = plt.subplots(figsize=(5, 6))
x = [1, 2, 3]

y = np.mean(all_double, axis=0)
yerr = np.std(all_double, axis=0) / (num_sub ** 0.5)
axs2.errorbar(x, y, yerr=yerr, fmt='-o', color='black', label='double')
y = np.mean(all_single1, axis=0)
yerr = np.std(all_single1, axis=0) / (num_sub ** 0.5)
axs2.errorbar(x, y, yerr=yerr, fmt='-o', color='tomato', label='single1')
y = np.mean(all_single2, axis=0)
yerr = np.std(all_single2, axis=0) / (num_sub ** 0.5)
axs2.errorbar(x, y, yerr=yerr, fmt='-o', color='dodgerblue', label='single2')

axs2.set_xticks(x)
axs2.set_xlabel("number of frame motion repetitions")
axs2.set_ylabel("localization error [dva]")
axs2.set_title(f"N = {num_sub}")
axs2.legend()
plt.tight_layout()
plt.show()
