#!/bin/bash

# note that if xbacklight is not working, it can probably be fixed by adding
# this to the xorg configuration (with the "Backlight" option replaced with
# the link name in /sys/class/backlight/ and adjusted driver of course)
# Section "Device"
#       Identifier  "Card0"
#       Driver      "intel"
#       Option      "Backlight"  "intel_backlight"
# EndSection

DEFAULT_ARGS='-steps 1 -time 1'
LC_ALL=C

function round_nearest() {
    printf '%.0f\n' "$1"
}

case $1 in
    +*)
        xbacklight $DEFAULT_ARGS -inc "${1#+}"
        ;;
    -*)
        CURR=$(round_nearest "$(xbacklight -get)")
        if [ "$((CURR - ${1#-}))" -ge 1 ]; then
            xbacklight $DEFAULT_ARGS -dec "${1#-}"
        fi
        ;;
    *)
        echo "usage: $0 {+,-}<num>" 1>&2
esac
