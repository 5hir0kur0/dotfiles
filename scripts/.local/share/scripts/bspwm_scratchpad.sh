#!/usr/bin/sh

SCRATCHCLASS=scratchpad-terminal

if ! xdotool search --class --classname "$SCRATCHCLASS" > /dev/null 2>&1; then
    st -c "$SCRATCHCLASS" -g 130x60 -e tmux new-session -As0 &
    sleep 0.1
fi

ID=$(xdotool search --class --classname $SCRATCHCLASS | head)

bspc node "$ID" --flag hidden
bspc node -f "$ID"
