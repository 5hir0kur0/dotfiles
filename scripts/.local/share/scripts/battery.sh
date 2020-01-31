#!/bin/bash

while :; do
    udev=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)
    level=$(grep percentage <<< "$udev" | grep -oP '\d+(?=%)')
    discharging=true
    if grep -qE 'state:\s*(charging|fully-charged)' <<< "$udev"; then
        discharging=false
    fi
    if ((level <= 14)) && [[ "$discharging" == true ]]; then
        systemctl hibernate
    elif ((level <= 30)) && [[ "$discharging" == true ]]; then
        notify-send -u critical "low battery level: ${level}%"
    elif ((90 <= level && level <= 95)) && [[ "$discharging" == false ]]; then
        notify-send -u low "battery full: ${level}%"
    fi
    # notify-send "battery: ${level}%"
    sleep 3m
done
