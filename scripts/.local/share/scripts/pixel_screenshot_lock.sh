#!/bin/bash
scrot -q 100 /tmp/.screen_locked.png
convert /tmp/.screen_locked.png -scale 10% -scale 1000% /tmp/.screen_locked.png
i3lock -i /tmp/.screen_locked.png