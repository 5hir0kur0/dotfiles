#!/bin/bash

set -uo pipefail

EMACS_DESKTOP=e
SCRATCHCLASS=Emacs


current_desktop() {
    wmctrl -d | grep -P '^\d+\s+\*' | rev | cut -f1 -d' ' | rev
}

start_emacs() {
    if pgrep -x bspwm; then
        bspwm_workspace.sh switch $EMACS_DESKTOP
    else
        i3-msg workspace $EMACS_DESKTOP
    fi
    emacs
}

emacs_running() {
    pgrep -x emacs
}

emacs_focused() {
    xprop WM_CLASS -id "$(xdotool getwindowfocus)" | grep -qF '"Emacs"'
}

workspace_back_and_forth() {
    if pgrep -x bspwm; then
        bspc desktop -f last
    else
        i3-msg workspace back_and_forth
    fi
}

emacs_scratchpad_toggle() {
    if pgrep -x bspwm; then
        # copied from bspwm_scratchpad.sh
        ID=$(xdotool search --class --classname $SCRATCHCLASS | head -1)
        DESKTOP="$(bspc query -D -d '.focused' -m focused)"
        # turning sticky off before moving the node fixes the problem of the
        # scratchpad not being moved to a different monitor
        bspc node "$ID" --flag sticky=off
        bspc node "$ID" -d "$DESKTOP"
        bspc node "$ID" --flag sticky=on
        bspc node "$ID" --flag hidden
        bspc node -f "$ID"
    else
        # this actually hides emacs when it is inside the scratchpad at that time
        i3-msg '[class="Emacs"] scratchpad show'
    fi
}

list_hidden_bspwm() {
    bspc query -N -n .hidden
}


emacs_window_focus() {
    if pgrep -x bspwm; then
        ID=$(xdotool search --class --classname $SCRATCHCLASS | head -1)

        if list_hidden_bspwm | grep -qi "$(printf 0x0*%x "$ID")"; then
            emacs_scratchpad_toggle
        else
            bspc node -f "$ID"
        fi
    else
        i3-msg '[class="Emacs"] focus'
    fi
}

if emacs_running; then
    if emacs_focused; then
        if [ "$(current_desktop)" = "$EMACS_DESKTOP" ]; then
            workspace_back_and_forth
        else
            emacs_scratchpad_toggle
        fi
    else
        emacs_window_focus
    fi
else
    start_emacs
fi
