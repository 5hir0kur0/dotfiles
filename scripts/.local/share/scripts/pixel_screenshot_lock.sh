#!/bin/bash

# depends on i3lock-color

colors=("--textcolor=ebdbb2ff" "--timecolor=ebdbb2ff" "--insidecolor=1d202142" \
        "--ringcolor=665c54aa" "--linecolor=50494542" "--keyhlcolor=a89984aa" \
        "--ringvercolor=bdae93aa" "--separatorcolor=665c54aa" \
        "--insidevercolor=1d2021aa" "--ringwrongcolor=cc241dbb" \
        "--insidewrongcolor=1d2021aa")

scrot -q 100 /tmp/.screen_locked.png

mogrify -scale 10% -scale 1000% \
    -level 0%,100%,0.9 \
    -fill black -colorize 42% \
    /tmp/.screen_locked.png

i3lock -i /tmp/.screen_locked.png -e --radius 210 --datestr='%F' -k \
    --datesize=21 --timesize=42 --timefont=Inconsolata --datefont=Inconsolata \
    --indicator --refresh-rate=1 --veriftext="..." --wrongtext="-_-" "${colors[@]}"
