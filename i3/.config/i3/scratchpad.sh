#!/bin/bash

# if SCRATCHCLASS is changed, $scratchclass in .config/i3/config
# needs to be changed too
SCRATCHCLASS='scratchpad-terminal'

if xdotool search --class --classname "$SCRATCHCLASS" > /dev/null 2>&1; then
    i3-msg "[instance=\"$SCRATCHCLASS\"] scratchpad show"
else
    pgrep -x urxvtd || urxvtd --fork
    urxvtc -name "$SCRATCHCLASS" -e tmux new-session -As0
fi