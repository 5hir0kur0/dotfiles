#!/bin/bash

FIFO_PATH=/tmp/.sxhkd
SXHKD_PATH=~/.config/sxhkd/sxhkdrc
MODE=
MODE_PREV=
PREV=

find_docstring() {
    MODE=$(grep -FB2 "$1" $SXHKD_PATH | grep -F '# MODE: ' | cut -d' ' -f3-)
}

while read -r LINE; do
    if [[ "$LINE" =~ ^EEnd\ chain ]]; then
        MODE=
    elif [[ "$LINE" =~ ^BBegin\ chain ]]; then
        find_docstring "${PREV#H}"
    elif [[ "$LINE" =~ ^H[^\;]+\;[^\;0-9]+$ ]]; then
        find_docstring "${LINE#H}"
    fi
    if [[ "$MODE" != "$MODE_PREV" ]]; then
        echo "$MODE"
    fi
    PREV=$LINE
    MODE_PREV=$MODE
done < $FIFO_PATH
