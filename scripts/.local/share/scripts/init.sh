#!/bin/sh

~/.local/share/scripts/kill.sh

pgrep -x urxvtd || urxvtd &
redshift-gtk &
~/.local/share/scripts/set_wallpaper.sh &
fcitx &
nm-applet &
dunst &
xautolock -time 42 -locker "$HOME/.local/share/scripts/exit.sh lock" &
udiskie --use-udisks2 --no-automount --smart-tray &
# i3 behaves buggy without noevents
unclutter -noevents -root -idle 8 &
keynav &
sleep 60 && syncthing &

[ ! -s ~/.config/mpd/pid ] && mpd &

exit 0
