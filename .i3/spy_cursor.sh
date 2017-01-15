#!/bin/sh

xprop -spy -root _NET_ACTIVE_WINDOW | while read; do
    ~/.i3/center_cursor.sh
done
