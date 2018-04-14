#!/bin/bash


monitor_info() {
    xrandr | grep -F "$(bspc query -M -m focused --names)" | grep -oP '\d+x\d+\+\d+\+\d+'
}

eval "$(xdotool getwindowfocus getwindowgeometry --shell)"
MONINFO=$(monitor_info)
SCREEN_WIDTH=$(grep -oP '\d+x\d+'       <<< "$MONINFO" | cut -dx -f1)
SCREEN_HEIGHT=$(grep -oP '\d+x\d+'      <<< "$MONINFO" | cut -dx -f2)
SCREEN_X_OFFSET=$(grep -oP '\+\d+\+\d+' <<< "$MONINFO" | cut -c2- | cut -d+ -f1)
SCREEN_Y_OFFSET=$(grep -oP '\+\d+\+\d+' <<< "$MONINFO" | cut -c2- | cut -d+ -f2)

case "$1" in
    ''|center)
        xdotool windowmove "$WINDOW" "$(( (SCREEN_WIDTH / 2) - (WIDTH / 2) + SCREEN_X_OFFSET ))" \
            "$(( (SCREEN_HEIGHT / 2) - (HEIGHT / 2) + SCREEN_Y_OFFSET ))"
        ;;
    left)
        xdotool windowmove "$WINDOW" $(( $(bspc config left_padding) + $(bspc config window_gap) + SCREEN_X_OFFSET )) "$Y"
        ;;
    right)
        xdotool windowmove "$WINDOW" "$(( SCREEN_WIDTH - WIDTH - $(bspc config right_padding) \
            - $(bspc config window_gap) - 2 * $(bspc config border_width) + SCREEN_X_OFFSET ))" "$Y"
        ;;
    top)
        xdotool windowmove "$WINDOW" "$X" $(( $(bspc config top_padding) + $(bspc config window_gap) + SCREEN_Y_OFFSET ))
        ;;
    bottom)
        xdotool windowmove "$WINDOW" "$X" "$(( SCREEN_HEIGHT - HEIGHT - $(bspc config window_gap) \
            - $(bspc config bottom_padding) - 2 * $(bspc config border_width) + SCREEN_Y_OFFSET ))"
        ;;
    *)
        echo "usage: $0 [center, right, top, bottom]" 1>&2
        exit 1
        ;;
esac
