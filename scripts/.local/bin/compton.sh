#!/bin/sh

current_id() {
    xprop -root | grep -oP '(?<=^_NET_ACTIVE_WINDOW\(WINDOW\): window id # ).+$'
}

invert_current() {
    picom --invert-color-include "client=$(current_id)"
}

kill_compton() {
    if pgrep -x picom; then pkill -x picom; fi
}

case "$1" in
    invert)
        kill_compton
        invert_current
        ;;
    kill)
        kill_compton
        ;;
    start)
        kill_compton
        picom
        ;;
    *)
        echo "Usage: $0 {invert|kill|start}"
        exit 2
esac

