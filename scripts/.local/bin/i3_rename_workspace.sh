#!/bin/sh

set -eu -o pipefail

WORKSPACE="$(rofi -dmenu -p 'rename workspace' < /dev/null)"

[ -n "$WORKSPACE" ] && i3-msg rename workspace to "\"$WORKSPACE\""
