#!/bin/sh

# usage: $ ./workspace.sh [move]

set -eu

list_non_numeric_workspaces() {
    i3-msg -t get_workspaces | grep --color=never -oP '(?<="name":")\D+?(?=")' \
        | sort --ignore-case
}

MOVE=""
[ -n "${1-}" ] && MOVE="move to "
WORKSPACE="$(list_non_numeric_workspaces | rofi -dmenu -p "$MOVE"'workspace:' -i)"

[ -n "$WORKSPACE" ] && i3-msg "${1-}" workspace "$WORKSPACE"
