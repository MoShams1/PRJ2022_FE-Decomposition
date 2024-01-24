import pandas as pd
import numpy as np
import os
from matplotlib import pyplot as plt


def bin_scatter(x, y, nbins=10, win=(-10, 10)):
    bins = np.linspace(win[0], win[1], num=nbins + 1)
    xmean = np.full(nbins, np.nan)
    ymean = np.full(nbins, np.nan)
    for ind, val in enumerate(bins):
        if ind <= len(bins) - 3:
            xmean[ind] = (bins[ind] + bins[ind + 1]) / 2
            temp = y[(x >= bins[ind]) & (x < bins[ind + 1])]
            if len(temp):
                ymean[ind] = sum(temp) / len(temp)
            else:
                pass
        elif ind == len(bins) - 2:
            xmean[ind] = (bins[ind] + bins[ind + 1]) / 2
            temp = y[(x >= bins[ind]) & (x <= bins[ind + 1])]
            if len(temp):
                ymean[ind] = sum(temp) / len(temp)
            else:
                pass
        else:
            pass
    return xmean, ymean


def find_target_files(path_name, exp_name):
    all_files = os.listdir(path_name)
    return [f for f in all_files if exp_name in f]


path = 'Data/CleanData'
exp = 'Exp03'
files = find_target_files(path, exp)

num_sub = 4
nbins = 10

win = (-10, 10)
all_err75 = np.full((num_sub, nbins), np.nan)
all_err50 = np.full((num_sub, nbins), np.nan)
all_err05 = np.full((num_sub, nbins), np.nan)

alpha = .8
linealpha = 1
offset1 = -.2
offset2 = -.3
offset3 = -.4
plt.style.use('seaborn')
fig, axs = plt.subplots(1, num_sub, figsize=(20, 5), sharey=True)

for i, file in enumerate(files):
    df = pd.read_json(os.path.join(path, file))

    dist = df['probe_xloc'] - df['frame_flashxloc']
    click_err = df['click1_xloc'] - df['probe_xloc']

    msk75 = df['frame_size'] == 7.5
    msk50 = df['frame_size'] == 5
    msk05 = df['frame_size'] == .5

    distb, click_errb75 = bin_scatter(dist[msk75], click_err[msk75],
                                      nbins=nbins, win=win)
    click_errb50 = bin_scatter(dist[msk50], click_err[msk50],
                               nbins=nbins, win=win)[1]
    click_errb05 = bin_scatter(dist[msk05], click_err[msk05],
                               nbins=nbins, win=win)[1]

    # errors = np.hstack([click_errb75, click_errb50, click_errb05])
    norm_coeff = 1

    click_errb75 = click_errb75 / norm_coeff
    click_errb50 = click_errb50 / norm_coeff
    click_errb05 = click_errb05 / norm_coeff

    axs[i].scatter(distb, click_errb75, c='black', alpha=alpha,
                   label='fr width: 7.5 deg')
    axs[i].scatter(distb, click_errb50, c='tomato', alpha=alpha,
                   label='fr width: 5 deg')
    axs[i].scatter(distb, click_errb05, c='dodgerblue', alpha=alpha,
                   label='fr width: 0.5 deg')

    axs[i].set_xlabel("probe's distance to frame's center [dva]")
    axs[i].set_title(file[-7:-5])

    all_err75[i, :] = click_errb75
    all_err50[i, :] = click_errb50
    all_err05[i, :] = click_errb05

axs[0].set_ylabel("absolute mislocalizatoin\n in the direction of frame's "
                  "motion [dva]")
axs[0].legend()

# plot average across subjects
fig2, (axs1, axs2, axs3) = plt.subplots(1, 3, figsize=(18, 5), sharey=True)
x = distb
# ======================================================
y = all_err75.mean(axis=0)
yerr = all_err75.std(axis=0) / (num_sub ** 0.5)
axs1.errorbar(x+7.5/2, y, yerr=yerr, fmt='-o', color='black',
              label='fr width: 7.5 deg')

y = all_err50.mean(axis=0)
yerr = all_err50.std(axis=0) / (num_sub ** 0.5)
axs1.errorbar(x+5/2, y, yerr=yerr, fmt='-o', color='tomato',
              label='fr width: 5 deg')

y = all_err05.mean(axis=0)
yerr = all_err05.std(axis=0) / (num_sub ** 0.5)
axs1.errorbar(x+.5/2, y, yerr=yerr, fmt='-o', color='dodgerblue',
              label='fr width: 0.5 deg')

axs1.set_xlabel("probe's distance to frame's back edge [dva]")
axs1.set_ylabel("absolute mislocalization\n in the direction of frame's "
                "motion [dva]")
axs1.legend(loc='upper left')
axs1.plot((0.5, 0), (offset1, offset1), alpha=linealpha, color='dodgerblue')
axs1.plot((5.0, 0), (offset2, offset2), alpha=linealpha, color='tomato')
axs1.plot((7.5, 0), (offset3, offset3), alpha=linealpha, color='black')
# ======================================================
y = all_err75.mean(axis=0)
yerr = all_err75.std(axis=0) / (num_sub ** 0.5)
axs2.errorbar(x, y, yerr=yerr, fmt='-o', color='black',
              label='fr width: 7.5 deg')

y = all_err50.mean(axis=0)
yerr = all_err50.std(axis=0) / (num_sub ** 0.5)
axs2.errorbar(x, y, yerr=yerr, fmt='-o', color='tomato',
              label='fr width: 5 deg')

y = all_err05.mean(axis=0)
yerr = all_err05.std(axis=0) / (num_sub ** 0.5)
axs2.errorbar(x, y, yerr=yerr, fmt='-o', color='dodgerblue',
              label='fr width: 0.5 deg')

axs2.set_xlabel("probe's distance to frame's center [dva]")
axs2.plot((-0.5/2, 0.5/2), (offset1, offset1), alpha=linealpha,
          color='dodgerblue')
axs2.plot((-5.0/2, 5.0/2), (offset2, offset2), alpha=linealpha, color='tomato')
axs2.plot((-7.5/2, 7.5/2), (offset3, offset3), alpha=linealpha, color='black')
# ======================================================
y = all_err75.mean(axis=0)
yerr = all_err75.std(axis=0) / (num_sub ** 0.5)
axs3.errorbar(x-7.5/2, y, yerr=yerr, fmt='-o', color='black',
              label='fr width: 7.5 deg')

y = all_err50.mean(axis=0)
yerr = all_err50.std(axis=0) / (num_sub ** 0.5)
axs3.errorbar(x-5/2, y, yerr=yerr, fmt='-o', color='tomato',
              label='fr width: 5 deg')

y = all_err05.mean(axis=0)
yerr = all_err05.std(axis=0) / (num_sub ** 0.5)
axs3.errorbar(x-.5/2, y, yerr=yerr, fmt='-o', color='dodgerblue',
              label='fr width: 0.5 deg')

axs3.set_xlabel("probe's distance to frame's front edge [dva]")
axs3.plot((-0.5, 0), (offset1, offset1), alpha=linealpha, color='dodgerblue')
axs3.plot((-5.0, 0), (offset2, offset2), alpha=linealpha, color='tomato')
axs3.plot((-7.5, 0), (offset3, offset3), alpha=linealpha, color='black')

fig2.suptitle(f"N={num_sub}")
plt.show()
