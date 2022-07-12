from psychopy import monitors, visual, event, core
from datetime import date


def config_mon_imac24():
    monitor = monitors.Monitor('prim_mon', width=54.7, distance=57)
    monitor.setSizePix([2240, 1260])
    return monitor


def config_win(mon, fullscr):
    win = visual.Window(monitor=mon,
                        units='deg',
                        size=[2240, 1260],
                        pos=[0, 0],
                        fullscr=fullscr,
                        color=[-.8, -.8, -.8])
    win.mouseVisible = True
    return win


def draw_fixdot(win, size, pos):
    fixdot = visual.TextStim(win=win,
                             text='+',
                             height=size,
                             pos=pos,
                             color='white')
    fixdot.draw()


def draw_frame(win, width, pos=(0, 0)):
    if width == 7.5:
        line_width = 0.3
    elif width == 5:
        line_width = 0.2
    else:
        line_width = 0.05
    outer_frame = visual.Rect(win=win,
                              size=width,
                              fillColor='white',
                              pos=pos)
    inner_frame = visual.Rect(win=win,
                              size=width - line_width,
                              fillColor=[-.8, -.8, -.8],
                              pos=pos)
    outer_frame.draw()
    inner_frame.draw()


def draw_probe(win, color, radius=.5, pos=(0, 0)):
    probe = visual.Circle(win,
                          radius=radius,
                          fillColor=color,
                          pos=pos)
    probe.draw()


def escape_session():
    exit_key = event.getKeys(keyList=['escape'])
    if 'escape' in exit_key:
        core.quit()


def get_date():
    today = date.today()
    return (str(today.year).zfill(4) +
            str(today.month).zfill(2) +
            str(today.day).zfill(2))


def opening_msg(win, task_num):
    if task_num == 1 or task_num == 2:
        msg = f'In this experiment, your task is to maintain your gaze at ' \
              f'the fixation cross and memorize the location of a single ' \
              f'dot (in red or blue) or two dots (in red and blue) that ' \
              f'flash.\n\n' \
              f'After the mouse cursor appears, you have to click at the ' \
              f'locations you memorized, while maintaining your ' \
              f'fixation.'
    else:
        msg = f'In this experiment, your task is to maintain your gaze at ' \
              f'the fixation cross and memorize the location of a single ' \
              f'red dot flashes.\n\n' \
              f'After the mouse cursor appears, you have to click at the ' \
              f'location you memorized, while maintaining your fixation.'

    inst_text = visual.TextStim(win, text=msg, color='white', height=.5,
                                alignText='left')
    inst_text.pos = (0, 2)
    inst_text.draw()

    commands = '[Escape]: Cancel\t[Space]: OK'
    cmnd_text = visual.TextStim(win, text=commands, color='white', height=.5,
                                alignText='right')
    cmnd_text.pos = (0, -2)
    cmnd_text.draw()

    win.flip()
    pressed_key = event.waitKeys(keyList=['space', 'escape'])
    if 'escape' in pressed_key:
        core.quit()
    elif 'space' in pressed_key:
        pass

    # show a blanck window for one second
    for iframe in range(60):
        win.flip()


def label_cnd(cnd):
    if cnd == 1:
        return 'single1'
    elif cnd == 2:
        return 'single2'
    else:
        return 'double'
