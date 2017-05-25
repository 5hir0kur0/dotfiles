#!/bin/bash

set -euo pipefail

list_workspaces() {
    i3-msg -t get_workspaces | grep --color=never -oP '(?<="name":")\d+?(?=")'
}

WORKSPACES="$(list_workspaces)"

for (( num=1; num >= 0; ++num )); do
    if ! grep -q "^$num\$" <<< "$WORKSPACES"; then
        i3-msg "${1-}" workspace "$num"
        exit
    fi
done
