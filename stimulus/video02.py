"""
To record a sample video from Experiment 2
Mohammad Shams <m.shams.ahmar@gmail.com>
August 2024
"""
from psychopy import event
import supplements as sup
import pandas as pd
import numpy as np
import random
import os
import warnings


warnings.simplefilter(action='ignore', category=FutureWarning)


# -------------------------------------------------
# insert session meta data
# -------------------------------------------------
person = 'MS'
n_trials = 30
# -------------------------------------------------
# destination file
# -------------------------------------------------
date = sup.get_date()
time = sup.get_time()
file_name = f"Exp02_{person}_{date}_{time}.json"
data_path = os.path.join('..', 'data', file_name)
# -------------------------------------------------
# initialize the display and set up task parameters
# -------------------------------------------------
# configure the monitor and the stimulus window
mon = sup.config_mon_macbookair()
win = sup.config_win(mon=mon, fullscr=True)

REF_RATE = 60
MIN_OBJ_DUR = 2  # frame

FR_WIDTH = 7.5  # deg
FR_PATH_LEN = 6  # deg
FR_PATH_DUR = 26  # frame
fr_nstops = int(FR_PATH_DUR / MIN_OBJ_DUR)  # num stops along frame's path
fr_xstart_list = [-4, -3, -2]  # deg
fr_y_list = [-1, 0, 1]  # deg

probe_size = .5  # radius in deg
probe_color_list = ['DodgerBlue', 'Tomato']

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
    # decide randomly on the trial condition
    # cnd1: single; first probe flashes
    # cnd2: single; second probe flashes
    # cnd3: double
    # cnd4: double
    cnd = random.choice([1, 2, 3, 4])

    # create frame's pathway
    fr_xstart = random.choice(fr_xstart_list)
    fr_y = random.choice(fr_y_list)
    fr_stops_arr = np.linspace(fr_xstart, fr_xstart + FR_PATH_LEN, fr_nstops)

    # randomly select the direction of frame's motion
    fr_dir = 'right'
    if random.choice([False, True]):
        fr_stops_arr = fr_stops_arr[::-1]
        fr_dir = 'left'

    # find the index and value of the midway of the frame's path
    fr_path_mid_val = fr_stops_arr[int((fr_nstops - 1) / 2)]

    # extract probe's location
    probe_x = fr_path_mid_val
    probe_y = fr_y

    # decide on the number of flashes
    nflashes = random.choice([1, 2])

    # randomly select color order of the proves
    random.shuffle(probe_color_list)
    # prepare probe visibility for save
    probe1_color = probe_color_list[0]
    probe2_color = probe_color_list[1]
    if cnd == 1:
        probe2_color = None
    elif cnd == 2:
        probe1_color = None

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
            # flash probe1
            if xind == 0 and cnd != 2:
                sup.draw_probe(win, pos=(probe_x, probe_y),
                               radius=probe_size,
                               color=probe_color_list[0])
            # flash probe2
            elif xind == fr_nstops - 1 and cnd != 1:
                sup.draw_probe(win, pos=(probe_x, probe_y),
                               radius=probe_size,
                               color=probe_color_list[1])
            win.flip()
            sup.escape_session()  # force exit with 'escape' button
            # core.wait(.1)  # slow down for debugging purposes

    # run gap period
    for igap in range(gap2_dur):
        win.flip()

    # run response period
    mouse = event.Mouse(visible=True, newPos=[cur_x * mpcc, cur_y * mpcc])

    if cnd == 1 or cnd == 2:
        nclicks = 1
    else:
        nclicks = 2

    click_loc = np.full((2, 2), np.nan)
    for iclick in range(nclicks):
        while not mouse.getPressed()[0]:
            sup.escape_session()  # force exit with 'escape' button
            win.flip()
        while mouse.getPressed()[0]:
            pass
        click_loc[iclick, :] = mouse.getPos() / mccc

    # prepare condition label for saving
    cnd_label = sup.label_cnd(cnd)
    # -------------------------------------------------
    # create data frame and save
    # -------------------------------------------------
    # create a dictionary
    trial_dict = {'trial_num': [itrial + 1],
                  'exp': [2],
                  'cnd': [cnd_label],
                  'probe_size': [probe_size],
                  'probe_xloc': [probe_x],
                  'probe_yloc': [probe_y],
                  'probe1_color': [probe1_color],
                  'probe2_color': [probe2_color],
                  'click1_xloc': [round(click_loc[0, 0], 2)],
                  'click1_yloc': [round(click_loc[0, 1], 2)],
                  'click2_xloc': [round(click_loc[1, 0], 2)],
                  'click2_yloc': [round(click_loc[1, 1], 2)],
                  'frame_size': [FR_WIDTH],
                  'frame_dur': [FR_PATH_DUR],
                  'frame_len': [FR_PATH_LEN],
                  'frame_startxloc': [fr_xstart],
                  'frame_startyloc': [fr_y],
                  'frame_nstops': [fr_nstops],
                  'frame_dir': [fr_dir],
                  'fixation_xloc': [fix_x],
                  'fixation_yloc': [fix_y],
                  'fixation_dur': [fix_dur],
                  'gap1_dur': [gap1_dur],
                  'gap2_dur': [gap2_dur]}
    # convert to data frame
    dfnew = pd.DataFrame(trial_dict)

    # if first trial create a file, else load and add the new data frame
    if itrial == 0:
        dfnew.to_json(data_path)
    else:
        df = pd.read_json(data_path)
        dfnew = pd.concat([df, dfnew], ignore_index=True)
        dfnew.to_json(data_path)

sup.end_screen(win, 'white')
