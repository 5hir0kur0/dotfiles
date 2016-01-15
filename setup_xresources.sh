#!/bin/bash

DIR="$(pwd)"

[ -f "$HOME/.Xresources" ] || ln -s "$DIR/.Xresources" "$HOME/.Xresources"
