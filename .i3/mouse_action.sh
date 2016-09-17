#!/bin/bash

# add your mouse regexes here
MOUSE_DEVICES=(^.*laser[[:space:]]*mouse.*$)

# comment this out if you want case-sensitive matching
shopt -s nocasematch

# call with xinput argument as argument
mouse_action() {
    xinput list --name-only | while read DEVICE; do
        for REGEX in "${MOUSE_DEVICES[@]}"; do
            if [[ "$DEVICE" =~ $REGEX ]]; then
                xinput $1 "$DEVICE"
            fi
        done
    done
}

# call with device name or id as argument
is_enabled() {
    ENABLED=`xinput list-props "$1" | grep 'Device Enabled' | cut -f 3`
    if [ "$ENABLED" -eq 1 ]; then
        return 0
    else
        return 1
    fi
}

toggle_mouse() {
    xinput list --name-only | while read DEVICE; do
        for REGEX in "${MOUSE_DEVICES[@]}"; do
            if [[ "$DEVICE" =~ $REGEX ]]; then
                if is_enabled "$DEVICE"; then xinput disable "$DEVICE"
                else xinput enable "$DEVICE"
                fi
            fi
        done
    done
}

case "$1" in
    enable)
        mouse_action enable
        ;;
    disable)
        mouse_action disable
        ;;
    toggle)
        toggle_mouse
        ;;
    *)
        echo "Usage: $0 {enable|disable|toggle}"
        exit 2
esac
