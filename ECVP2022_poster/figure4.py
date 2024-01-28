import pandas as pd
import numpy as np
import os
from matplotlib import pyplot as plt
import supplements as sup


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


path = 'Data'
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
offset1 = -.5
offset2 = -.6
offset3 = -.7
plt.style.use('seaborn')
# sup.init_figure()

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

    errors = np.hstack([click_errb75, click_errb50, click_errb05])
    norm_coeff = np.nanmean(errors)

    click_errb75 = click_errb75 / norm_coeff
    click_errb50 = click_errb50 / norm_coeff
    click_errb05 = click_errb05 / norm_coeff

    all_err75[i, :] = click_errb75
    all_err50[i, :] = click_errb50
    all_err05[i, :] = click_errb05

# plot average across subjects
fig, axs = plt.subplots(figsize=(9, 10))
colors = ['black', 'darkmagenta', 'violet']
lw = 3

x = distb
y = all_err05.mean(axis=0)
yerr = all_err05.std(axis=0) / (num_sub ** 0.5)
axs.errorbar(x + .5 / 2, y, yerr=yerr, fmt='-o', color=colors[2],
             linewidth=lw, label='fr width: 0.5 deg')
y = all_err50.mean(axis=0)
yerr = all_err50.std(axis=0) / (num_sub ** 0.5)
axs.errorbar(x + 5 / 2, y, yerr=yerr, fmt='-o', color=colors[1],
             linewidth=lw, label='fr width: 5 deg')
y = all_err75.mean(axis=0)
yerr = all_err75.std(axis=0) / (num_sub ** 0.5)
axs.errorbar(x + 7.5 / 2, y, yerr=yerr, fmt='-o', color=colors[0],
             linewidth=lw, label='fr width: 7.5 deg')

axs.set_xlabel("Probe's lead [dva]\n(wrt frame's trailing edge)")
axs.set_ylabel("Perceived location\n(withing subject normalized)")
axs.set_yticks(range(-1, 4))
axs.set_ylim([-1, 3])
axs.set_title(f'N = {num_sub}')
axs.legend(loc='upper left')
axs.plot((7.5, 0), (offset3, offset3), alpha=linealpha, color=colors[0],
         linewidth=lw * 2)
axs.plot((5.0, 0), (offset2, offset2), alpha=linealpha, color=colors[1],
         linewidth=lw * 2)
axs.plot((0.5, 0), (offset1, offset1), alpha=linealpha, color=colors[2],
         linewidth=lw * 2)

# plt.show()
script_name = os.path.basename(__file__)[:7]
fig.savefig(f"results/{script_name}_{exp}_probe2frame.pdf")
