#!/bin/sh

if tty | grep -q /dev/tty; then
    sg video -c "mplayer -vo fbdev2 -quiet -fs -zoom -xy 1920 '${1:?no file specified}'"
else
    mpv "${1:?no file specified}"
fi
