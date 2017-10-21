#!/bin/bash

# NOTE:
#  If you have the problem, that applications won't use the correct sink,
#  try installing "pulseaudio-alsa", because it might be because they're using
#  alsa directly. ;-)

UPPER_VOLUME_LIMIT=100 # the volume won't go above this limit
LOWER_VOLUME_LIMIT=0   # the volume won't go below this limit; has to be >= 0

# no idea if this works
export LC_ALL=C

default_sink() {
    pactl info | grep 'Default Sink:' | cut -f3 -d' '
}

sink_names() {
    pactl list sinks short | cut -f2
}

sink_input_ids() {
    pactl list sink-inputs short | cut -f1
}

mute_sinks() {
    for i in "${@}"; do
        pactl set-sink-mute "$i" true
    done
}

unmute_sinks() {
    for i in "${@}"; do
        pactl set-sink-mute "$i" false
    done
}

pretty_name() {
    pactl list sinks | grep "Name: $1" -A1 | tail -1 | tr -s ' '\
        | cut -f2- -d' '
}

# there has to be a better way for this, but I don't know it...
get_volume() {
    SINK="${1-$(default_sink)}"
    pactl list sinks\
        | pcregrep -Mi "Name:\s+$SINK\s*?\n(?:^\s*\S+.*?\n)+?\s*Volume:"\
        | tail -1 | tr -s ' ' | cut -d' ' -f5 | tr -d '%'
}

set_volume() {
    DEFAULT_SINK="$(default_sink)"
    unmute_sinks "$DEFAULT_SINK"
    NEW_VOLUME="$(get_volume)"
    NEW_VOLUME=$1
    if [ "$NEW_VOLUME" -le "$UPPER_VOLUME_LIMIT" ]; then
        pactl set-sink-volume "$DEFAULT_SINK" "$NEW_VOLUME%"
    else
        pactl set-sink-volume "$DEFAULT_SINK" "$UPPER_VOLUME_LIMIT%"
    fi
}

increase_volume() {
    DEFAULT_SINK="$(default_sink)"
    unmute_sinks "$DEFAULT_SINK"
    NEW_VOLUME="$(get_volume)"
    NEW_VOLUME=$((NEW_VOLUME + $1))
    if [ "$NEW_VOLUME" -le "$UPPER_VOLUME_LIMIT" ]; then
        pactl set-sink-volume "$DEFAULT_SINK" "$NEW_VOLUME%"
    else
        pactl set-sink-volume "$DEFAULT_SINK" "$UPPER_VOLUME_LIMIT%"
    fi
}

increase_volume_force() {
    DEFAULT_SINK="$(default_sink)"
    unmute_sinks "$DEFAULT_SINK"
    NEW_VOLUME="$(get_volume)"
    NEW_VOLUME=$((NEW_VOLUME + $1))
    pactl set-sink-volume "$DEFAULT_SINK" "$NEW_VOLUME%"
}

decrease_volume() {
    DEFAULT_SINK="$(default_sink)"
    unmute_sinks "$DEFAULT_SINK"
    NEW_VOLUME="$(get_volume)"
    NEW_VOLUME=$((NEW_VOLUME - $1))
    if [ "$NEW_VOLUME" -ge "$LOWER_VOLUME_LIMIT" ]; then
        pactl set-sink-volume "$DEFAULT_SINK" "$NEW_VOLUME%"
    else
        pactl set-sink-volume "$DEFAULT_SINK" "$LOWER_VOLUME_LIMIT%"
    fi
}

decrease_volume_force() {
    DEFAULT_SINK="$(default_sink)"
    unmute_sinks "$DEFAULT_SINK"
    NEW_VOLUME="$(get_volume)"
    NEW_VOLUME=$((NEW_VOLUME - $1))
    pactl set-sink-volume "$DEFAULT_SINK" "$NEW_VOLUME%"
}

index_of() { # $1: element, $2...: array
    ELEMENT=$1
    shift
    INDEX=0
    for i in "${@}"; do
        if [ "$i" = "$ELEMENT" ]; then
            echo $INDEX
            return
        fi
        INDEX=$((INDEX+1))
    done
    echo -1
}

toggle_default_sink_and_move_inputs() {
    SINKS=( $(sink_names) )
    DEFAULT_SINK=$(default_sink)
    DEFAULT_SINK_INDEX=$(index_of "$DEFAULT_SINK" "${SINKS[@]}")
    NUMBER_OF_SINKS=${#SINKS[@]}
    TARGET_SINK=${SINKS[$(((DEFAULT_SINK_INDEX + 1) % NUMBER_OF_SINKS))]}
    TARGET_SINK_INDEX=$(index_of "$TARGET_SINK" "${SINKS[@]}")
    pactl set-default-sink "$TARGET_SINK"
    unmute_sinks "$TARGET_SINK"

    # remove target sink and mute the others (just to make sure the other sinks
    # can't produce any sounds)
    SINKS[$TARGET_SINK_INDEX]=
    SINKS=(${SINKS[@]})
    mute_sinks "${SINKS[@]}"

    move_inputs_to_default
}

move_inputs_to_default() {
    SINK_INPUTS=( $(sink_input_ids) )
    for i in "${SINK_INPUTS[@]}"; do
        pactl move-sink-input "$i" "$(default_sink)"
    done
}

volume_notification() {
    notify-send -u low -i stock_volume -h "int:value:$(get_volume)" 'volume: %n%'
}

toggle_notification() {
    SINK=$(default_sink)
    notify-send -u low 'switch default sink to:' "$(pretty_name "$SINK")" \
        -i audio-card
}

mute_state() {
    pactl list sinks | grep -FA10 "$(default_sink)" \
        | grep -F 'Mute:' | rev | cut -d' ' -f1 | rev
}

case "$1" in
    set)
        set_volume "$2"
        volume_notification
        ;;
    up)
        increase_volume "${2-5}"
        volume_notification
        ;;
    down)
        decrease_volume "${2-5}"
        volume_notification
        ;;
    force_up)
        increase_volume_force "${2-5}"
        volume_notification
        ;;
    force_down)
        decrease_volume_force "${2-5}"
        volume_notification
        ;;
    mute)
        BEFORE_STATE="$(mute_state)"
        pactl set-sink-mute "$(default_sink)" ${2:-toggle}
        AFTER_STATE="$(mute_state)"
        if [[ "$BEFORE_STATE" != "$AFTER_STATE" ]]; then
            if [[ "$AFTER_STATE" == "no" ]]; then
                notify-send -u low -i stock_volume "mute: $AFTER_STATE"
            else
                notify-send -u low -i stock_volume-mute "mute: $AFTER_STATE"
            fi
        fi
        ;;
    toggle)
        toggle_default_sink_and_move_inputs
        toggle_notification
        ;;
    move)
        move_inputs_to_default
        ;;
    *)
        echo "Usage: $0 {set|up|down|force_up|force_down|mute|toggle|move}"
        exit 2
esac
