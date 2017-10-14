#!/bin/sh


monitor_info() {
    xrandr | grep -F "$(bspc query -M -m focused --names)" -A3 | grep -F '*'
}

eval "$(xdotool getwindowfocus getwindowgeometry --shell)"
SCREEN_WIDTH=$(monitor_info | grep -oP '\d+x\d+' | cut -dx -f1)
SCREEN_HEIGHT=$(monitor_info | grep -oP '\d+x\d+' | cut -dx -f2)

xdotool windowmove "$WINDOW" "$(( (SCREEN_WIDTH / 2) - (WIDTH / 2) ))" \
    "$(( (SCREEN_HEIGHT / 2) - (HEIGHT / 2) ))"
