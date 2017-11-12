#!/bin/bash

set -euo pipefail

SHOW=0
CLIP=0
DELAY=0
ACTION=whole
SHOWPROG=/usr/bin/sxiv
SCROTPROG=/usr/bin/scrot
MIMECOPY=~/.local/share/scripts/mimecopy.sh
QUALITY=75 # when using png, this affects the compression rate (100 = uncompressed)
source "${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs"
DIRECTORY="${XDG_PICTURES_DIR:-$HOME/pics}/"
FILENAME="scrot_%F_%T_\$wx\$h-$$"
SUFFIX=".png"
TMP_DIR=/tmp/scrots
SAVE=1

for ARG in "$@"; do
    case "$ARG" in
        -s|--show)
            SHOW=1
            ;;
        -c|--clip)
            CLIP=1
            ;;
        -n|--no-save)
            SAVE=0
            ;;
        -d=*|--delay=*)
            DELAY="${ARG#*=}"
            ;;
        -f=*|--dir=*)
            DIRECTORY="${ARG#*=}"
            ;;
        -a=*|--action=*)
            ACTION="${ARG#*=}"
            ;;
        --show-program=*|-p=*)
            SHOWPROG="${ARG#*=}"
            ;;
        *)
            echo "usage: $0 [-s|--show] [-c|--clip] [-n|--no-save] "\
                 "[-a=<action>|-action<action>] [-d=<secs>|--delay=<secs>]"\
                 " [--show-program=<program>|-p=<program>]" 1>&2
            echo 'actions: whole, window, window_borderless, select' 1>&2
            exit
            ;;
    esac
done

WHOLE_ARGS="--delay $DELAY --multidisp --quality $QUALITY"
WINDOW_ARGS="--delay $DELAY --focused --border --quality $QUALITY"
WINDOW_BORDERLESS_ARGS="--delay $DELAY --quality $QUALITY --focused"
SELECT_ARGS="--delay $DELAY --select --quality $QUALITY"

case "$ACTION" in
    whole)
        RUN="$SCROTPROG $WHOLE_ARGS"
        ;;
    window)
        RUN="$SCROTPROG $WINDOW_ARGS"
        ;;
    window_borderless)
        RUN="$SCROTPROG $WINDOW_BORDERLESS_ARGS"
        ;;
    select)
        RUN="$SCROTPROG $SELECT_ARGS"
        ;;
    *)
        echo "invalid action: $ACTION" 1>&2
        ;;
esac

if [ "$DELAY" != 0 ]; then
    RUN="$RUN"" --delay $DELAY"
fi

[ -d "$TMP_DIR" ] || mkdir "$TMP_DIR"

FILEPATH="$($RUN --exec 'echo $f' "$TMP_DIR/$FILENAME$SUFFIX")"
REALPATH="$(realpath "$FILEPATH")"
REALNAME="$(basename "$FILEPATH")"
SAVENAME="$(sed "s/-$$$SUFFIX\$/$SUFFIX/" <<< "$REALNAME")"

if [ "$SAVE" != 0 ]; then
    cp --backup=numbered "$REALPATH" "$DIRECTORY/$SAVENAME"
    REALPATH="$DIRECTORY/$SAVENAME"
fi

if [ "$CLIP" != 0 ]; then
    $MIMECOPY "$REALPATH" &
fi

if [ "$SHOW" != 0 ]; then
    $SHOWPROG "$REALPATH" &
fi
