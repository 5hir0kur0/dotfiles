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
        xdotool windowmove "$WINDOW" $(( $(bspc config left_padding)  + $(bspc config window_gap) )) "$Y"
        ;;
    right)
        xdotool windowmove "$WINDOW" "$(( SCREEN_WIDTH - WIDTH - $(bspc config right_padding) \
            - $(bspc config window_gap) - 2 * $(bspc config border_width) ))" "$Y"
        ;;
    top)
        xdotool windowmove "$WINDOW" "$X" $(( $(bspc config top_padding) + $(bspc config window_gap) ))
        ;;
    bottom)
        xdotool windowmove "$WINDOW" "$X" "$(( SCREEN_HEIGHT - HEIGHT - $(bspc config window_gap) \
            - $(bspc config bottom_padding) - 2 * $(bspc config border_width) ))"
        ;;
esac
