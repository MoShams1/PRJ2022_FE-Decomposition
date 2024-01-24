import pandas as pd
import numpy as np

file_name = 'Data/Exp03_20220711_MS_S01'
path = file_name + '.csv'
df = pd.read_csv(path)


def split_array(x, col, typ):
    return np.array([i[1:-1].split()[x] for i in df[col]], dtype=typ)


trial_num = np.array(df['trial_num'], dtype=int)
exp = np.full(np.shape(trial_num), 1)
# cnd = list(df['cnd'])
probe_size = np.array(df['probe_size'], dtype=float)
probe_xloc = split_array(0, 'probe_loc', float)
probe_yloc = split_array(1, 'probe_loc', float)
# probe1_color = list(df['probe1_color'])
# probe2_color = list(df['probe2_color'])
click1_xloc = split_array(0, 'click_loc', float)
click1_yloc = split_array(1, 'click_loc', float)
# click2_xloc = split_array(0, 'click2_loc', float)
# click2_yloc = split_array(1, 'click2_loc', float)
frame_size = np.array(df['frame_size'], dtype=float)
frame_dur = np.array(df['frame_dur'], dtype=int)
frame_len = np.array(df['frame_len'], dtype=int)
frame_startxloc = split_array(0, 'frame_startloc', float)
frame_startyloc = split_array(1, 'frame_startloc', float)
frame_nstops = np.array(df['frame_nstops'], dtype=int)
# frame_ncycles = np.array(df['frame_ncycles'], dtype=int)
frame_dir = list(df['frame_dir'])
frame_flashloc = list(df['frame_flashloc'])
fixation_xloc = split_array(0, 'fixation_loc', float)
fixation_yloc = split_array(1, 'fixation_loc', float)
fixation_dur = np.array(df['fixation_dur'], dtype=int)
gap1_dur = np.array(df['gap1_dur'], dtype=int)
gap2_dur = np.array(df['gap2_dur'], dtype=int)

mydict = {'trial_num': trial_num,
          'exp': exp,
          # 'cnd': cnd,
          'probe_size': probe_size,
          'probe_xloc': probe_xloc,
          'probe_yloc': probe_yloc,
          # 'probe1_color': probe1_color,
          # 'probe2_color': probe2_color,
          'click1_xloc': click1_xloc,
          'click1_yloc': click1_yloc,
          # 'click2_xloc': click2_xloc,
          # 'click2_yloc': click2_yloc,
          'frame_size': frame_size,
          'frame_dur': frame_dur,
          'frame_len': frame_len,
          'frame_startxloc': frame_startxloc,
          'frame_startyloc': frame_startyloc,
          'frame_nstops': frame_nstops,
          # 'frame_ncycles': frame_ncycles,
          'frame_dir': frame_dir,
          'frame_flashloc': frame_flashloc,
          'fixation_xloc': fixation_xloc,
          'fixation_yloc': fixation_yloc,
          'fixation_dur': fixation_dur,
          'gap1_dur': gap1_dur,
          'gap2_dur': gap2_dur}
mydf = pd.DataFrame(mydict)
mydf.to_json(file_name + '.json')
