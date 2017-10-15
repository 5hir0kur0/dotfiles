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
    wmctrl -l #| grep -vP ".+\s+$(current_desktop)\s+"
}

WINDOW=$(list_windows | rofi -dmenu -i -p 'fetch:' | cut -f1 -d' ')

if [[ "$(wm_name)" == bspwm ]]; then
    bspc node "$WINDOW" -d focused
    bspwm_workspace.sh reset
else
    wmctrl -R "$WINDOW"
fi
