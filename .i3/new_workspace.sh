#!/bin/sh

set -eu

list_workspaces() {
    i3-msg -t get_workspaces | grep --color=never -oP '(?<="name":")\d+?(?=")' \
        | sort --numeric-sort
}

last_workspace() {
    list_workspaces | tail -1
}

first_workspace() {
    list_workspaces | head -1
}

LAST="$(last_workspace)"
FIRST="$(first_workspace)"

if [ -n "$LAST" ]; then # if LAST exists, FIRST also exists
    if [ "$FIRST" -ge 2 ]; then
        i3-msg "${1-}" workspace "$((FIRST-1))"
    else
        i3-msg "${1-}" workspace "$((LAST+1))"
    fi
else
    i3-msg "${1-}" workspace "1"
fi
