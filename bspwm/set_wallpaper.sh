#!/bin/bash

wallpapers=(~/Bilder/wallpapers/*)
feh --bg-fill "${wallpapers[RANDOM % ${#wallpapers[@]}]}"
