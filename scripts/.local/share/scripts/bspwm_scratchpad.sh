#!/bin/bash

SCRATCHCLASS=scratchpad-terminal

ID=$(xdotool search --class --classname $SCRATCHCLASS | head -1)

list_hidden_no_scratchpad() {
    if [ -n "$ID" ]; then
        bspc query -N -n .hidden | grep -v "$(printf 0x%x "$ID")"
    else
        bspc query -N -n .hidden
    fi
}

list_floating() {
    bspc query -N -n '.floating.!hidden.local.leaf'
}

case "$1" in
    terminal)
        if ! xdotool search --class --classname "$SCRATCHCLASS" > /dev/null 2>&1; then
            st -c "$SCRATCHCLASS" -g 130x60 -e tmux new-session -As0 &
            sleep 0.1
        fi

        ID=$(xdotool search --class --classname $SCRATCHCLASS | head -1)

        bspc node "$ID" --flag hidden
        bspc node -f "$ID"
        ;;
    hide)
        bspc node --flag hidden
        ;;
    hide_floating)
        list_floating | while read -r F_ID; do
            bspc node "$F_ID" --flag hidden
        done
        ;;
    unhide)
        list_hidden_no_scratchpad | while read -r H_ID; do
            bspc node "$H_ID" --flag hidden
            bspc node "$H_ID" --state floating
        done
        ;;
    *)
        echo "usage: $0 {terminal|hide|hide_floating|unhide}" 1>&2
        ;;
esac
