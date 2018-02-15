#!/bin/sh


monitor_info() {
    xrandr | grep -F "$(bspc query -M -m focused --names)" -A3 | grep -F '*'
}

eval "$(xdotool getwindowfocus getwindowgeometry --shell)"
SCREEN_WIDTH=$(monitor_info | grep -oP '\d+x\d+' | cut -dx -f1)
SCREEN_HEIGHT=$(monitor_info | grep -oP '\d+x\d+' | cut -dx -f2)

case "$1" in
    ''|center)
        xdotool windowmove "$WINDOW" "$(( (SCREEN_WIDTH / 2) - (WIDTH / 2) ))" \
            "$(( (SCREEN_HEIGHT / 2) - (HEIGHT / 2) ))"
        ;;
    left)
        xdotool windowmove "$WINDOW" 0 "$Y"
        ;;
    right)
        xdotool windowmove "$WINDOW" "$(( SCREEN_WIDTH - WIDTH ))" "$Y"
        ;;
    top)
        xdotool windowmove "$WINDOW" "$X" 0
        ;;
    bottom)
        xdotool windowmove "$WINDOW" "$X" "$(( SCREEN_HEIGHT - HEIGHT ))"
        ;;
esac
