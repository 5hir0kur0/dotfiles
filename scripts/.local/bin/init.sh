#!/bin/sh

{ [ -x ~/.fehbg ] && ~/.fehbg; } || set_wallpaper.sh &

pgrep -x fcitx || { sleep 0.1; fcitx; } &
pgrep -x dunst || { sleep 0.15; dunst; } &
pgrep -x nm-applet || { sleep 0.2; nm-applet; } &
pgrep -x redshift-gtk || { sleep 0.5; redshift-gtk; } &
pgrep -x keynav || { sleep 0.9; keynav; } &
# i3 behaves buggy without noevents
pgrep -x udiskie || { sleep 1; udiskie --no-automount --smart-tray --notify; } &
pgrep -x unclutter || { sleep 5; unclutter -noevents -root -idle 8; } &
pgrep -x xautolock || { sleep 10; xautolock -time 42 -locker "$HOME/.local/bin/exit.sh lock"; } &

#[ ! -s ~/.config/mpd/pid ] && mpd &

exit 0
