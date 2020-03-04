# stolen from the ranger example plugins
# (https://github.com/ranger/ranger/blob/master/examples/plugin_fasd_add.py)

# This plugin adds opened directories to `autojump`

from __future__ import (absolute_import, division, print_function)

import subprocess

from pathlib import Path

import ranger.api


HOOK_INIT_OLD = ranger.api.hook_init


def hook_init(fm):
    def autojump_add(signal):
        prev = signal.previous.path if signal.previous else None
        curr = signal.new.path
        if prev and Path(curr) == Path(prev).parent:
            # if we're just navigating back up the directory tree this
            # shouldn't count as a visit for autojump
            return
        try:
            subprocess.run(['autojump', '--add', curr], check=True)
        except (subprocess.CalledProcessError, OSError) as e:
            fm.notify(str(e), bad=True)

    fm.signal_bind('cd', autojump_add)
    return HOOK_INIT_OLD(fm)


ranger.api.hook_init = hook_init
