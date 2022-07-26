

import pandas as pd
import numpy as np
import os
from matplotlib import pyplot as plt
import supplements as sup


def find_target_files(path_name, exp_name):
    all_files = os.listdir(path_name)
    return [f for f in all_files if exp_name in f]


path = 'Data/CleanData'
exp = 'Exp02'
files = find_target_files(path, exp)
num_sub = 5

# decide to plot the results with or without normalization
normalize = False

plt.style.use('seaborn')
sup.init_figure()

all_double1 = np.full((num_sub, 1), np.nan)
all_double2 = np.full((num_sub, 1), np.nan)
all_single1 = np.full((num_sub, 1), np.nan)
all_single2 = np.full((num_sub, 1), np.nan)

for i, file in enumerate(files):

    df = pd.read_json(os.path.join(path, file))

    # filter out the leftward motions
    msk_left = df['frame_dir'] == 'left'

    # click distance between two flashes
    msk_double = df['cnd'] == 'double'
    click1 = df.loc[msk_double, 'click1_xloc']
    click2 = df.loc[msk_double, 'click2_xloc']
    probe = df.loc[msk_double, 'probe_xloc']
    doubleA = click1 - probe
    doubleB = click2 - probe
    # flipt the sign of click errors in the leftward motion
    doubleA[msk_left] = -doubleA
    doubleB[msk_left] = -doubleB
    # find the maximum and minimum out of the two clicks
    double = pd.concat([doubleA, doubleB], axis=1)
    double1 = double.max(axis=1)
    double2 = double.min(axis=1)

    # single1: click error of the first and only flash
    msk_single = (df['cnd'] == 'single1')
    click = df.loc[msk_single, 'click1_xloc']
    probe = df.loc[msk_single, 'probe_xloc']
    single1 = (click - probe)
    # flipt the sign of click errors in the leftward motion
    single1[msk_left] = -single1

    # single2: click error of the first and only flash
    msk_single = (df['cnd'] == 'single2')
    click = df.loc[msk_single, 'click1_xloc']
    probe = df.loc[msk_single, 'probe_xloc']
    single2 = (click - probe)
    # flipt the sign of click errors in the leftward motion
    single2[msk_left] = -single2

    if normalize:
        # normalize the errors within each subject
        errors = pd.concat([double1, double2, single1, single2])
        double1 = double1 / errors.mean()
        double2 = double2 / errors.mean()
        single1 = single1 / errors.mean()
        single2 = single2 / errors.mean()

    all_double1[i] = double1.mean()
    all_double2[i] = double2.mean()
    all_single1[i] = single1.mean()
    all_single2[i] = single2.mean()

# plot across subject figures
fig, axs = plt.subplots(figsize=(9, 5))
y = [1, 1, 2, 2]
data = np.hstack([all_double1, all_double2, all_single1, all_single2])
x = np.mean(data, axis=0)
xerr = np.std(data, axis=0) / (num_sub ** 0.5)
axs.barh(y, width=x, xerr=xerr)
axs.set_xlim(left=-2, right=4)
axs.set_xlabel('Perceived location [dva]')
axs.set_yticks(y)
axs.set_title(f"N = {num_sub}")

plt.tight_layout()
# plt.show()
script_name = os.path.basename(__file__)[:7]
fig.savefig(f"Results/{script_name}_{exp}_perceptionErr.pdf")
