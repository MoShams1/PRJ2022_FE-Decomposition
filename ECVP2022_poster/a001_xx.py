# df = pd.read_json('Data/Exp01_AC.json')
# msk1 = (df['cnd'] == 'double') & (df['frame_ncycles'] == 1)
# msk2 = (df['cnd'] == 'double') & (df['frame_ncycles'] == 2)
# msk3 = (df['cnd'] == 'double') & (df['frame_ncycles'] == 3)
#
# clk1 = df.loc[msk1, 'click1_xloc']
# clk2 = df.loc[msk1, 'click2_xloc']
# click_dist_rep1 = abs(clk1 - clk2)
# clk1 = df.loc[msk2, 'click1_xloc']
# clk2 = df.loc[msk2, 'click2_xloc']
# click_dist_rep2 = abs(clk1 - clk2)
# clk1 = df.loc[msk3, 'click1_xloc']
# clk2 = df.loc[msk3, 'click2_xloc']
# click_dist_rep3 = abs(clk1 - clk2)
# bins = np.arange(0, 10, .4)
# alpha = .7
# plt.hist(click_dist_rep1, bins=bins, alpha=alpha, label='double',
#          color='black')
# plt.hist(click_dist_rep2, bins=bins, alpha=alpha, label='double',
#          color='tomato')
# plt.hist(click_dist_rep3, bins=bins, alpha=alpha, label='double',
#          color='dodgerblue')
# plt.show()