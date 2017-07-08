#!/bin/bash

set -euo pipefail

HISTORY=/tmp/.wallpaper_history

WALLPAPER=

if [ "${1:-}" = 'pop' ] && [ -f $HISTORY ] && \
   [ "$(wc -l $HISTORY | cut -f1 -d\ )" -ge 1 ]; then
    sed -i '$d' $HISTORY # delete comes first b/c last line is current wallpaper
    WALLPAPER=$(tail -1 $HISTORY)
else
    WALLPAPERS=(~/pics/wall/*)
    WALLPAPER=${WALLPAPERS[RANDOM % ${#WALLPAPERS[@]}]}
    echo "$WALLPAPER" >> $HISTORY
fi

feh --bg-fill "$WALLPAPER" &
