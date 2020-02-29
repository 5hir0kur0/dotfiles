#!/bin/bash

if [ -d "$1" ]; then
    LEN=$(ls -w "$((COLUMNS/2))" --color -A -C "$1" | wc -l)
    if [ "$LEN" -gt "$((LINES/3))" ]; then
        ls -w "$((COLUMNS/2))" --color -C "$1"
    else
        ls -w "$((COLUMNS/2))" --color -A -C "$1"
    fi
else
    source /usr/share/doc/ranger/config/scope.sh "$1" "$((COLUMNS/2))" "$((LINES/3))" "$HOME/.thumbnails" False
fi
