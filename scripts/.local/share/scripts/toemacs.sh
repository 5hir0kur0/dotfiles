#!/bin/bash

set -euo pipefail

EMACS_DESKTOP=e


current_desktop() {
    wmctrl -d | grep -P '^\d+\s+\*' | rev | cut -f1 -d' ' | rev
}

start_emacs() {
    i3 workspace e
    emacs
}

emacs_running() {
    pgrep -x emacs
}

emacs_focused() {
    xprop WM_CLASS -id "$(xdotool getwindowfocus)" | grep -qF '"Emacs"'
}

if emacs_running; then
    if emacs_focused; then
        if [ "$(current_desktop)" = "$EMACS_DESKTOP" ]; then
            i3-msg workspace back_and_forth
        else
	    # this actually hides emacs when it is inside the scratchpad at that time
	    i3-msg '[class="Emacs"] scratchpad show'
        fi
    else
        i3-msg '[class="Emacs"] focus'
    fi
else
    start_emacs
fi
