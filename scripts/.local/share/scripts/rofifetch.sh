#!/bin/bash

wm_name() {
    wmctrl -m | grep -oP '(?<=Name: )(.+)$' 
}

function list_windows {
    wmctrl -l | grep -iEv "$(bspwm_current_desktop_regex)"
}

function bspwm_current_desktop_regex {
    readarray -t current < <(bspc query --nodes --desktop focused)
    local IFS='|'
    echo "(${current[*]})"
}


if [[ "$(wm_name)" == bspwm ]]; then
    
    WINDOW=$(list_windows | rofi -dmenu -i -p 'fetch' | cut -f1 -d' ')
    bspc node "$WINDOW" -d focused
    bspwm_workspace.sh reset
else
    # swap default action and alt action in rofi's window mode to allow 
    # executing the command by default, the "Control+F13" is just a random 
    # keybinding and not intended to be used
    # TODO maybe exclude the current workspace
    WINDOW=$(rofi -modi window -show window -kb-accept-entry 'Control+F13' \
        -kb-accept-alt 'Return,Control+j,Control+m,KP_Enter' \
        -window-command 'echo {window}')
    # bring window to current desktop
    wmctrl -i -R "$WINDOW"
    if [[ "$(wm_name)" == i3 ]]; then
        # focus manually in i3
        # (because currently I have my i3 set up to ignore focus requests...)
        i3-msg "[id=${WINDOW}]" focus
    fi

fi
