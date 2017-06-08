#!/bin/bash

set -euo pipefail

PROG=$1
TMPD=/tmp/.rofi_interactive_tmp

exec 2>&1

[ -d "$TMPD" ] || mkdir "$TMPD"

OUTPUT=$TMPD/$PROG/out
INPUT=$TMPD/$PROG/in

if [ ! -d "$TMPD/$PROG" ]; then
    mkdir "$TMPD/$PROG"
    touch "$TMPD/$PROG/in"
    # please, someone forgive me for this...
    tail -f "$INPUT" | script --quiet --return --command "$PROG 1>> $OUTPUT 2>&1" "$TMPD/script" &
    PID=$!
    echo "$PID" > "$TMPD/$PROG/pid"
    echo "STARTED: $PID"
fi

cd "$TMPD/$PROG" || rofi -e "<span color='red'><b>This won't ever happen</b></span>" -markup
# PID=$(head ./pid)
# STDIN=/proc/$PID/fd/0

ARGS=
FIRST=1
PS1=
PS2=
export PS1 PS2
while true; do
    touch $OUTPUT # or alternatively truncate -s 0 $OUTPUT (if the output should be truncated then in the `script` line 1>> needs to be changed to 1>

    if [ "$FIRST" -ne 1 ]; then
        echo "$ARGS"  >> $OUTPUT
        echo "$ARGS" >> $INPUT
        sleep 0.042 # this value is completely arbitrary...
    else
        FIRST=0
    fi

    ROWS=$(wc -l $OUTPUT | cut -f1 -d\ )
    # truncating for some reason causes lots of NUL bytes...
    ARGS=$(sed 's/\x00//g' < $OUTPUT | rofi -selected-row "$((ROWS-1))" -dmenu -p "$PROG:" \
        -kb-accept-custom Return -kb-accept-entry Control+Return) || break
done

if [ -d "$TMPD/$PROG" ]; then
    echo killing "$PROG"
    cd "$TMPD/$PROG" || rofi -e "<span color='red'><b>This won't ever happen</b></span>" -markup
    PID=$(head ./pid)
    kill "$PID"
    cd /tmp || exit 1
    rm -r "${TMPD:-?}/$PROG"
fi
