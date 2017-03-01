#!/bin/sh

set -eu

last_workspace() {
    i3-msg -t get_workspaces | grep --color=never -oP '(?<="name":")\d+?(?=")' \
        | sort --numeric-sort | tail -1
}

LAST="$(last_workspace)"

if [ -n "$LAST" ]; then
    i3-msg "${1-}" workspace "$((LAST+1))"
else
    i3-msg "${1-}" workspace "1"
fi
