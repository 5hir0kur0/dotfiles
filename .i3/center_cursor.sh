#!/bin/sh

# center the cursor relative to the currently active window
# requirements: xdotool

CURRENT_ID="`xdotool getwindowfocus`"
eval "`xdotool getwindowgeometry --shell $CURRENT_ID`"

xdotool mousemove --window "$CURRENT_ID" "$((WIDTH / 2))" "$((HEIGHT / 2))"
