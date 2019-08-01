#!/bin/bash

set -euo pipefail

mark_exists() {
    i3-msg -t get_marks | grep -qF "\"${1?}\""
}

if mark_exists "${1:?$0 needs a mark string as argument}"; then
    echo "window is already marked as ${1}" 1>&2
    exit 1
else
    i3-msg "mark --add \"${1:?no mark string given}\""
fi
