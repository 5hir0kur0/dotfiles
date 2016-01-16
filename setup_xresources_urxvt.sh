#!/bin/bash

DIR="$(pwd)"

[ -f "$HOME/.Xresources" ] || ln -s "$DIR/.Xresources" "$HOME/.Xresources"
[ -d "$HOME/.urxvt" ]      || ln -s "$DIR/.urxvt" "$HOME/.urxvt"
