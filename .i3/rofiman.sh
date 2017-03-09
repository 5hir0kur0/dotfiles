#!/bin/bash

set -eu -o pipefail

list_man_pages() {
    man -k .
}

get_name() {
    list_man_pages | rofi -dmenu -i -p 'man:' -matching regex -filter '^'
}

TEMP="$(get_name)"
NAME="$(cut -d ' ' -f 1 -s <<< "$TEMP")"
SECTION="$(tr ')' '(' <<< "$TEMP" | cut -d '(' -f 2 -s)"

if [[ -z "$SECTION" || -z "$NAME" ]]; then
    echo "invalid man name" 1>&2
    exit 1
fi

if tmux list-sessions >& /dev/null; then
   tmux neww -n "man $NAME" "man $SECTION $NAME"
else
    rofi-sensible-terminal -e man "$SECTION" "$NAME"
fi
