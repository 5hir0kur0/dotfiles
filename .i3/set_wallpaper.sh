#!/bin/bash

wallpapers=(/home/nerd/Bilder/wallpapers/*)
feh --bg-fill "${wallpapers[RANDOM % ${#wallpapers[@]}]}"
