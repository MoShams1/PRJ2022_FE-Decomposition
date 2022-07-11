"""
This script runs the third experiment (out of three) and is aimed for
ECVP2022.
Specifically, the goal here is to study the absolute perceived location of
single flashed probes in a unidirectional moving frame with two varaibles of
interest:
    a. flash distance to the frame
    b. frame size

Mohammad Shams
m.shams.ahmar@gmail.com
2022-Jul-10
"""
from psychopy import event
import supplements as sup
import pandas as pd
import numpy as np
import random
import os

# -------------------------------------------------
# insert session meta data
# -------------------------------------------------
person = 'MS'
session = '01'  # use '00' for test sessions
n_trials = 100  # 3 x 100
# -------------------------------------------------
# destination file
# -------------------------------------------------
date = sup.get_date()
file_name = f"Exp03_{date}_{person}_S{session}.csv"
data_path = os.path.join('Data', file_name)
# -------------------------------------------------
# initialize the display and set up task parameters
# -------------------------------------------------
# configure the monitor and the stimulus window
mon = sup.config_mon_imac24()
win = sup.config_win(mon=mon, fullscr=False)

REF_RATE = 60
MIN_OBJ_DUR = 2  # frame

fr_width_arr = [1, 5, 7.5]  # deg
FR_PATH_LEN = 20  # deg
FR_PATH_DUR = 86  # frame
fr_nstops = int(FR_PATH_DUR / MIN_OBJ_DUR)  # num stops along frame's path
fr_xstart_list = [-11, -10, -9]  # deg
fr_y_list = [-1, 0, 1]  # deg

probe_size = .5  # radius in deg
PROBE_COLOR = 'Tomato'

FIX_SIZE = .7
FIX_OFFSET = 5  # deg
fix_dur_list = list(range(48, 72 + 1, 6))  # frame (= 800,1200,100 ms)

gap_dur_list = list(range(18, 42 + 1, 6))  # frame (= 300,700,100 ms)

CUR_OFFSET = 3  # cursor y offset in deg
mpcc = 2  # mouse pointer correction coefficient (found impirically)
mccc = 4  # mouse click correction coefficient (found impirically)
# -------------------------------------------------
# show the opening message window
# -------------------------------------------------
sup.opening_msg(win, task_num=2)
# #################################################
#                   TRIAL X
# #################################################
for itrial in range(n_trials):
    # hide the cursor
    mouse = event.Mouse(win=win, visible=False)
    # -------------------------------------------------
    # set up the stimulus behavior in current trial
    # -------------------------------------------------
    # create frame's pathway
    fr_xstart = random.choice(fr_xstart_list)
    fr_y = random.choice(fr_y_list)
    fr_stops_arr = np.linspace(fr_xstart, fr_xstart + FR_PATH_LEN, fr_nstops)

    # randomly select the direction of frame's motion
    fr_dir = 'right'
    # if random.choice([False, True]):
    #     fr_stops_arr = fr_stops_arr[::-1]
    #     fr_dir = 'left'

    # randomly select the frame size
    FR_WIDTH = random.choice(fr_width_arr)

    # find the index and value of the midway of the frame's path
    fr_path_mid_val = fr_stops_arr[int((fr_nstops - 1) / 2)]

    # randomly select when the probe flashes
    fr_flashloc = random.choice(fr_stops_arr)

    # extract probe's location
    probe_x = fr_path_mid_val
    probe_y = fr_y

    # randomly decide on fixation duration
    fix_dur = random.choice(fix_dur_list)

    # extract where the fixation dot appears
    fix_x = fr_path_mid_val
    fix_y = fr_y + FIX_OFFSET

    # randomly decide on gap duration
    gap1_dur = random.choice(gap_dur_list)
    gap2_dur = random.choice(gap_dur_list)

    # randomly select where the cursor appears
    cur_x = fix_x
    cur_y = fr_y - CUR_OFFSET
    # -------------------------------------------------
    # run the stimulus
    # -------------------------------------------------
    # run fixation period
    for ifix in range(fix_dur):
        sup.draw_fixdot(win=win, size=FIX_SIZE, pos=(fix_x, fix_y))
        win.flip()

    # run gap period
    for igap in range(gap1_dur):
        win.flip()

    # move the frame and flash the probes
    for xind, xval in enumerate(fr_stops_arr):
        for irep in range(MIN_OBJ_DUR):
            sup.draw_frame(win, pos=(xval, fr_y),
                           width=FR_WIDTH)
            # flash probe
            if xval == fr_flashloc:
                sup.draw_probe(win, pos=(probe_x, probe_y),
                               radius=probe_size,
                               color=PROBE_COLOR)
            win.flip()
            sup.escape_session()  # force exit with 'escape' button
            # core.wait(.1)  # slow down for debugging purposes

    # run gap period
    for igap in range(gap2_dur):
        win.flip()

    # run response period
    mouse = event.Mouse(visible=True, newPos=[cur_x * mpcc, cur_y * mpcc])

    while not mouse.getPressed()[0]:
        sup.escape_session()  # force exit with 'escape' button
        win.flip()
    while mouse.getPressed()[0]:
        pass
    click_loc = mouse.getPos() / mccc
    # -------------------------------------------------
    # create data frame and save
    # -------------------------------------------------
    print(fr_flashloc)
    # create a dictionary
    trial_dict = {'trial_num': [itrial + 1],
                  'probe_size': [probe_size],
                  'probe_loc': [np.array([probe_x, probe_y])],
                  'click_loc': [np.around(click_loc, 2)],
                  'frame_size': [FR_WIDTH],
                  'frame_dur': [FR_PATH_DUR],
                  'frame_len': [FR_PATH_LEN],
                  'frame_startloc': [np.array([fr_xstart, fr_y])],
                  'frame_flashloc': [np.around(fr_flashloc, 2)],
                  'frame_nstops': [fr_nstops],
                  'frame_dir': [fr_dir],
                  'fixation_loc': [np.array([fix_x, fix_y])],
                  'fixation_dur': [fix_dur],
                  'gap1_dur': [gap1_dur],
                  'gap2_dur': [gap2_dur]}
    # convert to data frame
    dfnew = pd.DataFrame(trial_dict)
    # if first trial create a file, else load and add the new data frame
    if itrial == 0:
        dfnew.to_csv(data_path, index=False)
    else:
        df = pd.read_csv(data_path)
        dfnew = pd.concat([df, dfnew])
        dfnew.to_csv(data_path, index=False)
