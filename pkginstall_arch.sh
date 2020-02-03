#!/bin/bash

set -euo pipefail

TMP_FILE=$(mktemp /tmp/pkglist.XXXX)

if [[ -z "${1:-}" ]]; then
    echo "usage: $0 <pkglist>" 1>&2
    exit 1
fi

while read -r -u 10 PKG; do
    echo -n "Install $PKG? [Y/n] "
    read -r ANSWER
    if [[ -z "${ANSWER:-}" || "${ANSWER,,}" = y ]]; then
        echo "$PKG" >> "$TMP_FILE"
    fi
done 10< "$1"

less "$TMP_FILE"
echo -n "continue? [Y/n] "
read -r ANSWER
if [[ -z "${ANSWER:-}" || "${ANSWER,,}" = y ]]; then
    echo "Installing packages..."
    # shellcheck disable=SC2024
    sudo pacman -Sy - < "$TMP_FILE"
fi
