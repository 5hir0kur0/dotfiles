#!/bin/bash

export LC_ALL=C

BAT_PATH=/sys/class/power_supply/BAT0

if ! [ -e "$BAT_PATH" ]; then
    exit 1
fi

while :; do
    read -r level < $BAT_PATH/capacity
    discharging=''
    if grep -qi 'discharging' $BAT_PATH/status; then
        discharging=true
    fi
    if ((level <= 14)) && [[ "$discharging" ]]; then
        i3-nagbar -m "Battery critically low: ${level}%" -B Hibernate 'exit.sh hibernate' -B Suspend 'exit.sh suspend' -B 'Hybrid Sleep' 'exit.sh hybrid_sleep'
    elif ((level <= 30)) && [[ "$discharging" ]]; then
        notify-send -u critical "low battery level: ${level}%"
    elif ((90 <= level && level <= 94)) && ! [[ "$discharging" ]]; then
        notify-send -u low "battery almost full: ${level}%"
    fi
    # notify-send "battery: ${level}%"
    sleep 1m
done
