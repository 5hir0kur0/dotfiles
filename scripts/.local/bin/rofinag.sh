#!/bin/bash

# function stolen from https://stackoverflow.com/a/17841619
function join_by { local IFS="$1"; shift; echo "$*"; }


function run_rofi {
    join_by $'\n' "${LINES[@]}" | \
        rofi -dmenu -no-custom -no-click-to-exit -sync "-$2auto-select" \
             -case-sensitive -lines 1 -no-show-match -filter '^' \
             -p 'type a letter or escape' -columns "${#LINES[@]}" \
             -hide-scrollbar -matching regex -mesg "$1"
}

if [ -z "$1" ]; then
    echo "usage: echo 'choices' | $0 <message> <exec_1>, <exec_2>, ..."
    exit 1
fi

# TODO: use readarray or something
LINES=()
while read -r LINE; do
    LINES+=("$LINE")
done

CHOICE=
if [ "${#LINES[@]}" -gt 1 ]; then
    CHOICE="$(run_rofi "$1" '')"
else
    CHOICE="$(run_rofi "$1" no-)"
fi
EXIT=$?

shift

if [ $EXIT -eq 0 ]; then
    # stolen from https://stackoverflow.com/a/15028821
    for i in "${!LINES[@]}"; do
        if [ "${LINES[$i]}" = "${CHOICE}" ]; then
            i=$((i+1))
            eval "${!i}"
            exit
        fi
    done
else
    exit $EXIT
fi
