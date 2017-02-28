#!/bin/sh

~/.i3/kill.sh

pgrep -x urxvtd || urxvtd &
redshift-gtk &
~/.i3/set_wallpaper.sh &
fcitx &
nm-applet &
dunst &
xautolock -time 42 -locker "$HOME/.i3/exit.sh lock" &
udiskie --use-udisks2 --no-automount --smart-tray &
# i3 behaves buggy without noevents
unclutter -noevents -root -idle 8 &
keynav &

exit 0
