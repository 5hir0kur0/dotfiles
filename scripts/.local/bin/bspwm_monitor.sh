#!/bin/bash

# Sadly, this script causes bspwm to crash sometimes :(

case $1 in
    next)
        bspc desktop -m next --follow \
            || bspc desktop -m prev --follow \
            || (DESK=$(bspc query -D --names -d focused -m focused)
                bspwm_workspace.sh switch_new
                bspwm_workspace.sh switch_to "$DESK"
                bspc desktop "$DESK" -m next --follow) \
            || (DESK=$(bspc query -D --names -d focused -m focused)
                bspwm_workspace.sh switch_new
                bspwm_workspace.sh switch_to "$DESK"
                bspc desktop "$DESK" -m prev --follow)
        ;;
    prev)
        bspc desktop -m prev --follow \
            || bspc desktop -m next --follow \
            || (DESK=$(bspc query -D --names -d focused -m focused)
                bspwm_workspace.sh switch_new
                bspwm_workspace.sh switch_to "$DESK"
                bspc desktop "$DESK" -m prev --follow) \
            || (DESK=$(bspc query -D --names -d focused -m focused)
                bspwm_workspace.sh switch_new
                bspwm_workspace.sh switch_to "$DESK"
                bspc desktop "$DESK" -m next --follow)
        ;;
    *)
        echo "usage: $0 {next|prev}" >&2
        exit 1
esac
