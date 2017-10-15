#!/bin/bash

set -euo pipefail

list_workspaces() {
    bspc query -D --names | sort -n
}

list_numeric_workspaces() {
    bspc query -D --names | grep -P '\d+' | sort -n
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
}

switch_to() {
    create_if_nonexistent "$1"
    bspc desktop -f "$1"
}

move_to() {
    create_if_nonexistent "$1"
    bspc node -d "$1"
}

join_by() { local IFS="$1"; shift; echo "$*"; }

reset() {
    readarray -t DESKTOPS < <(cat <(bspc query --names -D -d '.occupied' -m focused) <(bspc query --names -D -d -m focused) | sort | uniq)
    bspc monitor -d "${DESKTOPS[@]}"
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
