#!/bin/bash

colors=("--verifcolor=f9f5d7ff" "--wrongcolor=f9f5d7ff" "--timecolor=f9f5d7ee" "--insidecolor=1d202180" \
        "--ringcolor=504945aa" "--linecolor=28282800" "--keyhlcolor=f9f5d7ee" \
        "--ringvercolor=458588ff" "--separatorcolor=28282800" \
        "--insidevercolor=1d2021aa" "--ringwrongcolor=cc241dff" \
        "--insidewrongcolor=fb4934aa" "--datecolor=f9f5d7dd")

scrot -q 100 /tmp/.screen_locked_tmp.png
#mogrify -blur 21x21 /tmp/.screen_locked.png
ffmpeg -i /tmp/.screen_locked_tmp.png -vf 'curves=increase_contrast, boxblur=9:9:lr=6:ar=6, curves=vintage' -y /tmp/.screen_locked.png

rm -f /tmp/.screen_locked_tmp.png

pgrep -x i3lock || i3lock -i /tmp/.screen_locked.png -e --radius=240 --datestr='%F' -k \
    --datesize=30 --timesize=48 --time-font=Inconsolata --date-font=Inconsolata \
    --indicator --veriftext="..." --wrongtext="-_-" "${colors[@]}" \
    --datepos='tx : ty + 35' --modsize=32 --verifsize=32 --wrongsize=32
