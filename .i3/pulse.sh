#!/bin/bash

# NOTE:
#  If you have the problem, that applications won't use the correct sink,
#  try installing "pulseaudio-alsa", because it might be because they're using
#  alsa directly. ;-)

UPPER_VOLUME_LIMIT=100 # the volume won't go above this limit
LOWER_VOLUME_LIMIT=0   # the volume won't go below this limit; has to be >= 0

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
    SINK="${1-`default_sink`}"
    pactl list sinks\
        | pcregrep -Mi "Name:\s+$SINK\s*?\n(?:^\s*\S+.*?\n)+?\s*Volume:"\
        | tail -1 | tr -s ' ' | cut -d' ' -f5 | tr -d '%'
}

increase_volume() {
    DEFAULT_SINK="`default_sink`"
    unmute_sinks "$DEFAULT_SINK"
    NEW_VOLUME="`get_volume`"
    NEW_VOLUME=$((NEW_VOLUME + $1))
    if [ "$NEW_VOLUME" -le "$UPPER_VOLUME_LIMIT" ]; then
        pactl set-sink-volume "$DEFAULT_SINK" "$NEW_VOLUME%"
    else
        pactl set-sink-volume "$DEFAULT_SINK" "$UPPER_VOLUME_LIMIT%"
    fi
}

decrease_volume() {
    DEFAULT_SINK="`default_sink`"
    unmute_sinks "$DEFAULT_SINK"
    NEW_VOLUME="`get_volume`"
    NEW_VOLUME=$((NEW_VOLUME - $1))
    if [ "$NEW_VOLUME" -ge "$LOWER_VOLUME_LIMIT" ]; then
        pactl set-sink-volume "$DEFAULT_SINK" "$NEW_VOLUME%"
    else
        pactl set-sink-volume "$DEFAULT_SINK" "$LOWER_VOLUME_LIMIT%"
    fi
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
    SINKS=(`sink_names`)
    DEFAULT_SINK=`default_sink`
    DEFAULT_SINK_INDEX=`index_of $DEFAULT_SINK ${SINKS[@]}`
    NUMBER_OF_SINKS=${#SINKS[@]}
    TARGET_SINK=${SINKS[$(((DEFAULT_SINK_INDEX + 1) % NUMBER_OF_SINKS))]}
    TARGET_SINK_INDEX=`index_of $TARGET_SINK ${SINKS[@]}`
    pactl set-default-sink $TARGET_SINK
    unmute_sinks $TARGET_SINK

    # remove target sink and mute the others (just to make sure the other sinks
    # can't produce any sounds)
    SINKS[$TARGET_SINK_INDEX]=
    SINKS=(${SINKS[@]})
    mute_sinks "${SINKS[@]}"

    move_inputs_to_default

    notify-send "Switch audio output to “`pretty_name $TARGET_SINK`”"\
        -i audio-card
}

move_inputs_to_default() {
    SINK_INPUTS=(`sink_input_ids`)
    for i in "${SINK_INPUTS[@]}"; do
        pactl move-sink-input "$i" "`default_sink`"
    done
}

case "$1" in
    up)
        increase_volume ${2-5}
        ;;
    down)
        decrease_volume ${2-5}
        ;;
    mute)
        pactl set-sink-mute "`default_sink`" toggle
        ;;
    toggle)
        toggle_default_sink_and_move_inputs
        ;;
    move)
        move_inputs_to_default
        ;;
    *)
        echo "Usage: $0 {up|down|mute|toggle|move}"
        exit 2
esac
