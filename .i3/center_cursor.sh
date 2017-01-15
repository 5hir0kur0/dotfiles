#!/bin/sh

current_id() {
    xprop -root | grep '^_NET_ACTIVE_WINDOW(WINDOW):' | rev | cut -d\  -f1 | rev
}

current_width() {
    xwininfo -id "`current_id`" | grep -i '^\s*width:' | rev | cut -d\  -f1 | rev
}

current_height() {
    xwininfo -id "`current_id`" | grep -i '^\s*height:' | rev | cut -d\  -f1 | rev
}

WIDTH="`current_width`"
HEIGHT="`current_height`"

xdotool mousemove --window "`current_id`" "$((WIDTH / 2))" "$((HEIGHT / 2))"
