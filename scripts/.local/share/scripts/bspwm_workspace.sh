#!/bin/bash

set -uo pipefail

list_workspaces() {
    bspc query -D --names | sort
}

list_non_numeric_workspaces() {
    bspc query -D --names | grep -vP '^\d+$' | sort
}

list_numeric_workspaces() {
    bspc query -D --names | grep -P '^\d+$' | sort
}

create_numeric() {
    WORKSPACES="$(list_numeric_workspaces)"
    for (( num=1; num >= 0; ++num )); do
        if ! grep -q "^$num\$" <<< "$WORKSPACES"; then
            echo "$num"
            exit
        fi
    done
}

create_if_nonexistent() {
    list_workspaces | grep "^$1\$" || bspc monitor -a "$1"
    reorder
}

switch_to() {
    create_if_nonexistent "$1"
    bspc desktop -f "$1"
}

move_to() {
    create_if_nonexistent "$1"
    bspc node -d "$1"
}

reorder() {
    readarray -t DESKTOPS < <(bspc query --names -D -m focused | sort -fV)
    bspc monitor -o "${DESKTOPS[@]}" # doesn't seem to do anything
}

reset() {
    # reorder
    # readarray -t DESKTOPS < <(cat \
    #     <(bspc query --names -D -d '.occupied' -m focused) \
    #     <(bspc query --names -D -d -m focused) | awk '!seen[$0]++')
    # # awk command stolen from: https://unix.stackexchange.com/a/11941
    # bspc monitor -d "${DESKTOPS[@]}"
    
    # remove unoccupied desktops instead of a hard reset
    IFS=$'\n' DESKTOPS=($(bspc query -D -d '.!occupied.!focused' -m focused))
    for ID in "${DESKTOPS[@]}"; do
        bspc desktop "$ID" -r
    done
    reorder
}

case "${1:?}" in
    switch)
        switch_to "${2:?}"
        reset
        ;;
    move)
        move_to "${2:?}"
        reset
        ;;
    switch_rofi)
        WORKSPACE="$(list_non_numeric_workspaces | rofi -dmenu -i -p 'workspace:')"
        if [ -n "$WORKSPACE" ]; then
            switch_to "$WORKSPACE"
            reset
        fi
        ;;
    move_rofi)
        WORKSPACE="$(list_non_numeric_workspaces | rofi -dmenu -i -p 'move to workspace:')"
        if [ -n "$WORKSPACE" ]; then
            move_to "$WORKSPACE"
            reset
        fi
        ;;
    switch_new)
        switch_to "$(create_numeric)"
        reset
        ;;
    move_new)
        move_to "$(create_numeric)"
        reset
        ;;
    reset)
        reset
        ;;
esac
