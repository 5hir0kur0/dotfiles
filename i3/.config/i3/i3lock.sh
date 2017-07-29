#!/bin/bash

# use the background that was set using feh
# (does not seem to work for jpg, only png)
BACKGROUND="`expr match "$(cat ~/.fehbg)" '.*'"'"'\(.\+\)'"'"''`"
i3lock -tdi "$BACKGROUND"
