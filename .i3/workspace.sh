#!/bin/sh

i3-msg workspace "$(dmenu.xft -p 'New workspace:' -fn 'DejaVu Sans Mono-11' -nb '#101010' -nf '#b9b9b9' -sb '#b9b9b9' -sf '#101010' -i < /dev/null)"
