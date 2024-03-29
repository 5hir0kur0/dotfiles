#!/bin/bash

NAMES=('urxvtd'
       'redshift-gtk'
       'redshift'
       'fcitx'
       'nm-applet'
       'dunst'
       'xautolock'
       'udiskie'
       'unclutter'
       'keynav'
       'sxhkd'
       'polybar'
       'picom'
)

for NAME in "${NAMES[@]}"; do
    pkill -x "$NAME"
done

exit 0
