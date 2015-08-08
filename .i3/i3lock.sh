#!/bin/bash
wallpapers=(/home/nerd/Bilder/wallpapers/*.png)
i3lock -tdi "${wallpapers[RANDOM % ${#wallpapers[@]}]}"
