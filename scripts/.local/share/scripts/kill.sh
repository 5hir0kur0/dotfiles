#!/bin/sh

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
)

for NAME in "${NAMES[@]}"; do
    pkill -x "$NAME"
done

exit 0
