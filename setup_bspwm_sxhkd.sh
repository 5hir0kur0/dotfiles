#!/bin/bash

DIR="$(pwd)"

[ -d "$HOME/.config" ]            || mkdir "$HOME/.config"
[ -d "$HOME/.config/bspwm" ]      || ln -s "$DIR/bspwm" "$HOME/.config/bspwm"
[ -d "$HOME/.config/sxhkd" ]      || ln -s "$DIR/sxhkd" "$HOME/.config/sxhkd"
