#!/bin/sh

current_id() {
    xprop -root | grep -oP '(?<=^_NET_ACTIVE_WINDOW\(WINDOW\): window id # ).+$'
}

invert_current() {
    compton --invert-color-include "client=`current_id`"
}

kill_compton() {
    if pgrep -x compton; then pkill -x compton; fi
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
        compton
        ;;
    *)
        echo "Usage: $0 {invert|kill|start}"
        exit 2
esac

