#!/bin/bash

wm_name() {
    wmctrl -m | grep -oP '(?<=Name: )(.+)$' 
}

current_desktop() {
    case "$(wm_name)" in
        bspwm)
            bspc query -D -d -m focused --names
            ;;
        *)
            echo not implemented for "$(wm_name)" yet 1>&2
            exit 1
            ;;
    esac
}

list_windows() {
    wmctrl -l | grep -vP ".+\s+$(current_desktop)\s+"
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
