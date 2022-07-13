import pandas as pd
import numpy as np

path = 'Data/Exp01_20220711_MS_S01.csv'
df = pd.read_csv(path)

trial_num = np.array(df['trial_num'], dtype=int)
cnd = list(df['cnd'])
probe_size = np.array(df['probe_size'], dtype=float)

# temp = np.array(df['probe_loc'])
# probe_loc = [np.asfarray(i, float) for i in df['probe_loc']]
probe_loc = np.asfarray(probe_size[0, :], float)

# print(type(probe_loc))
print(probe_loc)
# print(probe_loc[0])
# print(np.array(df.loc[1, 'probe_loc']))

# print(probe_loc[0] + probe_loc[1])

# mydic = {'trial_num': trial_num,
#          'cnd': cnd,
#          'probe_size': probe_size}
# mydf = pd.DataFrame(mydic)
# print(mydf)

# trial_num = list(df['cnd'])
'''
trial_dict = {'trial_num': [itrial + 1],
              'cnd': [cnd_label],
              'probe_size': [probe_size],
              'probe_loc': [np.array([probe_x, probe_y])],
              'probe1_color': [probe1_color],
              'probe2_color': [probe2_color],
              'click1_loc': [np.around(click_loc[0, :], 2)],
              'click2_loc': [np.around(click_loc[1, :], 2)],
              'frame_size': [FR_WIDTH],
              'frame_dur': [FR_PATH_DUR],
              'frame_len': [FR_PATH_LEN],
              'frame_startloc': [np.array([fr_xstart, fr_y])],
              'frame_nstops': [fr_nstops],
              'frame_ncycles': [n_cycles],
              'frame_dir': [fr_dir],
              'fixation_loc': [np.array([fix_x, fix_y])],
              'fixation_dur': [fix_dur],
              'gap1_dur': [gap1_dur],
              'gap2_dur': [gap2_dur]}
'''
