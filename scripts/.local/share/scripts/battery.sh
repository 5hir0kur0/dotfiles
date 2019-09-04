#!/bin/bash

acpi_listen | while read -r event; do
    if ! [[ "$event" =~ .*battery.* ]]; then
        continue
    fi
    udev=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)
    level=$(grep percentage <<< "$udev" | grep -oP '\d+(?=%)')
    discharging=true
    if grep -qE 'state:\s*(charging|fully-charged)' <<< "$udev"; then
        discharging=false
    fi
    if ((level <= 8)) && [ "$discharging" = true ]; then
        systemctl hibernate
    elif ((level <= 20)) && [ "$discharging" = true ]; then
        notify-send "low battery level: ${level}%"
    # elif ((level >= 99)) && [ "$charging" = true ]; then
    #     notify-send "battery full: ${level}%"
    fi
    # notify-send "battery: ${level}%"
done
