#!/bin/sh

set -eu

COUNT=0
LIMIT=100

# focus topmost container
while true; do
    if [ "$((COUNT++))" -gt "$LIMIT" ]; then
        break
    fi
    if i3-msg focus parent | grep -q '"success":\s*false'; then
        break
    fi
done

[ -n "${1:-}" ] && i3-msg split "$1"
[ -n "${2:-}" ] && $2
