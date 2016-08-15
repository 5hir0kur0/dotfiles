#!/bin/sh

pgrep -x urxvtd || urxvtd &
pkill -x 'redshift-gtk'
redshift-gtk &
~/.i3/set_wallpaper.sh &
pkill -x 'fcitx'
fcitx &
pkill -x 'nm-applet'
nm-applet &
pkill -x 'xautolock'
xautolock -time 42 -locker '~/.i3/exit.sh lock' &
