#!/bin/bash

if [ -z "$1" ]; then
    echo usage: $0 [-v] FILE
    exit 1
fi

VERBOSE=

if [ -n "$2" -a "$1" = "-v" ]; then
    VERBOSE=1
    shift
fi

MIMETYPE=`file -b --mime-type "$1"`
[ "$VERBOSE" ] && echo mimetype: $MIMETYPE

if [[ "$MIMETYPE" =~  ^text/.+$ ]]; then
    xclip -selection clipboard "$1"
else
    xclip -selection clipboard -t "$MIMETYPE" "$1"
fi
