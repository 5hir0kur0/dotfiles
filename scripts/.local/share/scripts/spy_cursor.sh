#!/bin/sh

# whenever a new window is focused, center the cursor in the new window
# (NOTE: this also happens when you focus the window by moving the mouse)
# requirements: xprop

xprop -spy -root _NET_ACTIVE_WINDOW | while read; do
    # this fixes weird behavior when switing to an empty i3 workspace
    if ! xprop -id "`xdotool getwindowfocus`" | grep -q '^WM_NAME'; then
        continue
    fi
    ~/.local/share/scripts/center_cursor.sh
done
