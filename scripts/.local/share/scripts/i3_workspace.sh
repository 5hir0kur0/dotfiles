#!/bin/sh

set -u

list_non_numeric_workspaces() {
    i3-msg -t get_workspaces | grep --color=never -oP '(?<="name":")(?:\D+?|1[1-9]|[^1]\d+|\d\d\d+)(?=")' \
        | sort --ignore-case
}

MOVE=""
[ -n "${1-}" ] && MOVE="move to "
WORKSPACE="$(list_non_numeric_workspaces | rofi -dmenu -p "$MOVE"'workspace:' -i)"

[ -n "$WORKSPACE" ] && i3-msg "${1-}" workspace "$WORKSPACE"
