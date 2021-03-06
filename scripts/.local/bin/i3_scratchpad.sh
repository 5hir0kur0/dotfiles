#!/bin/bash

# if SCRATCHCLASS is changed, $scratchclass in .config/i3/config
# needs to be changed too
SCRATCHCLASS='scratchpad-terminal'

if xdotool search --class "$SCRATCHCLASS" > /dev/null 2>&1; then
    i3-msg "[class=\"$SCRATCHCLASS\"] scratchpad show" || i3-msg "[class=\"$SCRATCHCLASS\"] focus"
elif xdotool search --classname "$SCRATCHCLASS" > /dev/null 2>&1; then
    i3-msg "[instance=\"$SCRATCHCLASS\"] scratchpad show" || i3-msg "[instance=\"$SCRATCHCLASS\"] focus"
else
    # st -c "$SCRATCHCLASS" -g 160x46 -e tmux new-session -As0
    alacritty --class "$SCRATCHCLASS" --command tmux new-session -As0
fi
