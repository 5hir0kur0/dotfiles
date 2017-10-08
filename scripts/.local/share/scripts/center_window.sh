#!/bin/sh

eval "$(xdotool getwindowfocus getwindowgeometry --shell)"
SCREEN_WIDTH=$(xrandr | grep -F '*' | grep -oP '\d+x\d+' | cut -dx -f1)
SCREEN_HEIGHT=$(xrandr | grep -F '*' | grep -oP '\d+x\d+' | cut -dx -f2)

xdotool windowmove "$WINDOW" "$(( (SCREEN_WIDTH / 2) - (WIDTH / 2) ))" \
    "$(( (SCREEN_HEIGHT / 2) - (HEIGHT / 2) ))"
