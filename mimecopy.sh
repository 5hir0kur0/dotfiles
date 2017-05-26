#!/bin/bash

# dependencies: xclip, imagemagick (convert)

if [ -z "$1" ]; then
    echo usage: $0 [-c] FILE
    exit 1
fi

CONVERT=
VERBOSE=

if [ -n "$2" -a "$1" = "-c" ]; then
    CONVERT=1
    shift
fi

MIMETYPE=`file -b --mime-type "$1"`
[ "$VERBOSE" ] && echo mimetype: $MIMETYPE

if [[ "$MIMETYPE" =~  ^text/.+$ ]]; then
    xclip -selection clipboard "$1"
elif [[ "$MIMETYPE" =~ ^image/.+$ && "$MIMETYPE" != 'image/png' && $CONVERT ]]
then
    TMPPATH="/tmp/.mimecpy-$$.png"
    [ "$VERBOSE" ] && echo "converting image ($1) to png ($TMPPATH)"
    if hash ffmpeg >& /dev/null; then
        ffmpeg -i "$1" "$TMPPATH" >& /dev/null
    elif hash convert >& /dev/null; then
        convert "$1" "$TMPPATH"
    else
        echo "neither convert nor ffmpeg are installed" >2
    fi
    xclip -selection clipboard -t 'image/png' "$TMPPATH"
else
    xclip -selection clipboard -t "$MIMETYPE" "$1"
fi
