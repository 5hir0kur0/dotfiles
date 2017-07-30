#!/bin/bash

set -euo pipefail

TMP_FILE=/tmp/.pkglist

if [ -z "${1:-}" ]; then
    echo "usage: $0 <pkglist>" 1>&2
    echo "  (use --no to simulate)" 1>&2
    exit 1
fi

while read -r -u 10 PKG; do
    echo -n "install $PKG? [Y/n] "
    read -r ANSWER
    if [ -z "$ANSWER" ] || [ "${ANSWER,,}" = y ]; then
        echo "$PKG" >> "$TMP_FILE"
    fi
done 10< "$1"

sudo pacman -Sy - < "$TMP_FILE"
