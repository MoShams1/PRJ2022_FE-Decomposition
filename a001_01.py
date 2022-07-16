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
bins = np.arange(0, 5, .2)

all_double = np.full((num_sub, 1), np.nan)
all_single1 = np.full((num_sub, 1), np.nan)
all_single2 = np.full((num_sub, 1), np.nan)

for i, file in enumerate(files):
    df = pd.read_json(os.path.join(path, file))

    # click distance between two flashes
    msk_double = df['cnd'] == 'double'
    click1 = df.loc[msk_double, 'click1_xloc']
    click2 = df.loc[msk_double, 'click2_xloc']
    dist_double = abs(click1 - click2)

    axs1[0, i].hist(dist_double, bins=bins)
    axs1[0, i].set_title(f"double-subj#{i + 1}")
    axs1[0, i].set_ylabel('count')

    # single1: click error of the first and only flash
    msk_single1 = df['cnd'] == 'single1'
    click = df.loc[msk_single1, 'click1_xloc']
    probe = df.loc[msk_single1, 'probe_xloc']
    dist_single1 = abs(click - probe)

    axs1[1, i].hist(dist_single1, bins=bins)
    axs1[1, i].set_title(f"single1-subj#{i + 1}")
    axs1[1, i].set_ylabel('count')

    # single2: click error of the second and only flash
    msk_single2 = df['cnd'] == 'single2'
    click = df.loc[msk_single2, 'click1_xloc']
    probe = df.loc[msk_single2, 'probe_xloc']
    dist_single2 = abs(click - probe)

    axs1[2, i].hist(dist_single2, bins=bins)
    axs1[2, i].set_title(f"single2-subj#{i + 1}")
    axs1[2, i].set_xlabel('absolute localization error [dva]')
    axs1[2, i].set_ylabel('count')

    all_double[i] = dist_double.mean()
    all_single2[i] = dist_single2.mean()
    all_single1[i] = dist_single1.mean()

# plot across subject figures
fig2, axs2 = plt.subplots(figsize=(5, 6))
x = [1, 2, 3]
data = np.hstack([all_double, all_single1, all_single2])
y = np.mean(data, axis=0)
yerr = np.std(data, axis=0) / (num_sub ** 0.5)
# yerr = np.std(data, axis=0)
axs2.bar(x, y)
axs2.errorbar(x, y, yerr=yerr, fmt='none', ecolor='black')
axs2.set_xticks(x)
axs2.set_xticklabels(['double', 'single1', 'single2'])
axs2.set_ylabel("localization error [dva]")
axs2.set_title(f"N = {num_sub}")
plt.show()
