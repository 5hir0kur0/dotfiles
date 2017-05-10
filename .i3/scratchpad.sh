#!/bin/bash

# if SCRATCHCLASS is changed, you need to change $scratchclass in .i3/config too
SCRATCHCLASS='scratchpad-terminal'

if xdotool search --class "$SCRATCHCLASS" > /dev/null 2>&1; then
    i3-msg scratchpad show
else
    st -c "$SCRATCHCLASS" -e tmux new-session -As0
fi
