#!/bin/bash

set -eu

list() {
    locate ~ | grep -v "^$HOME.*/\\..\\|^$HOME/misc"
}

FILENAME="$(list | rofi -levenshtein-sort -dmenu -p 'xdg:' -i)"

[ -z "$FILENAME" ] && exit

case "$1" in
    xdg)
        xdg-open "$FILENAME"
        ;;
    term)
        if tmux list-sessions >& /dev/null; then
            tmux neww -n "${FILENAME##*/}" "rifle '""$FILENAME""'"
        else
            rofi-sensible-terminal -e rifle "$FILENAME"
        fi
        ;;
    *)
        echo "usage: $0 xdg|term"
        ;;
esac
