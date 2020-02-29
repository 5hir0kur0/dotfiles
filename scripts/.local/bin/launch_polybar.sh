#!/usr/bin/env bash

# stolen from https://github.com/jaagr/polybar/issues/763

old_bars=$(pgrep -x polybar)

primary=$(xrandr --query | grep -P " connected .*primary" | cut -d" " -f1)
MONITOR=$primary polybar bspwm &

if type "xrandr"; then
  for m in $(xrandr --query | grep -P " connected \\d+" | cut -d" " -f1); do
    MONITOR=$m polybar bspwm_secondary &
  done
else
  polybar bspwm &
fi

for bar in $old_bars; do
    kill "$bar"
done
