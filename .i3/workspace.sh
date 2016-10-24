#!/bin/sh

i3-msg move workspace "$(dmenu -p 'New workspace:' -fn 'DejaVu Sans Mono-11' -nb '#101010' -nf '#b9b9b9' -sb '#b9b9b9' -sf '#101010' -i < /dev/null)"
