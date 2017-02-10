#!/bin/sh

pgrep -x urxvtd || urxvtd &
pkill -x 'redshift-gtk'
redshift-gtk &
~/.i3/set_wallpaper.sh &
pkill -x 'fcitx'
fcitx &
pkill -x 'nm-applet'
nm-applet &
pkill -x 'dunst'
dunst &
pkill -x 'xautolock'
xautolock -time 42 -locker '~/.i3/exit.sh lock' &
pkill -x 'udiskie'
udiskie --use-udisks2 --no-automount --smart-tray &
pkill -x 'unclutter'
# i3 behaves buggy without noevents
unclutter -noevents -root -idle 8 &
keynav &
