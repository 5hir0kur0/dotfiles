#!/bin/sh

i3-msg workspace "$(dmenu.xft -p 'New workspace:' -fn 'DejaVu Sans Mono-11' -nb '#073642' -nf '#eee8d5' -sb '#b58900' -sf '#002b36' -i < /dev/null)"
