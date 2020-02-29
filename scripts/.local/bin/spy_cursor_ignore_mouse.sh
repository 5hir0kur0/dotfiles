#!/bin/sh

# position the mouse in the center of a window, when it is focused by the wm
# (do nothing if the window was focused by moving the mouse)
# requirements: xdotool

mouse_location() {
    eval "`xdotool getmouselocation --shell`"
    echo "$X|$Y"
}

xprop -spy -root _NET_ACTIVE_WINDOW | while read; do
    # see if the mouse is moving; this is fairly hacky, but it's the only thing
    # that I could get to work...

    # this fixes weird behavior when switing to an empty i3 workspace
    if ! xprop -id "`xdotool getwindowfocus`" | grep -q '^WM_NAME'; then
        continue
    fi

    MOUSE_OLD="`mouse_location`"
    sleep 0.0042
    MOUSE_NEW="`mouse_location`"

    if [ "$MOUSE_OLD" = "$MOUSE_NEW" ]; then
        ~/.local/bin/center_cursor.sh
    fi
done
