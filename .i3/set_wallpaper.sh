#!/bin/bash

wallpapers=(~/pics/wall/*)
feh --bg-fill "${wallpapers[RANDOM % ${#wallpapers[@]}]}"
