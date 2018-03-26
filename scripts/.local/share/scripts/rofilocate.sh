#!/bin/bash

set -eu

list() {
    locate ~ | grep -Ev "/\.\w+|/misc/apps/"
}

FILENAME="$(list | rofi -levenshtein-sort -dmenu -p 'xdg' -i)"

[ -z "$FILENAME" ] && exit

case "$1" in
    xdg)
        xdg-open "$FILENAME"
        ;;
    term)
        if tmux list-sessions >& /dev/null; then
            if [ -d "$FILENAME" ]; then
                tmux neww -n "${FILENAME##*/}" -c "$FILENAME"
            else
                tmux neww -n "${FILENAME##*/}" "rifle '""$FILENAME""'"
            fi
        else
            if [ -d "$FILENAME" ]; then
                urxvt -cd "$FILENAME"
            else
                rofi-sensible-terminal -e rifle "$FILENAME"
            fi
        fi
        ;;
    *)
        echo "usage: $0 xdg|term"
        ;;
esac
