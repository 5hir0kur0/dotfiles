#!/bin/bash

default_sink() {
    pactl info | grep 'Default Sink:' | cut -f3 -d' '
}

sink_names() {
    pactl list sinks short | cut -f2
}

sink_input_ids() {
    pactl list sink-inputs short | cut -f1
}

pretty_name() {
    pactl list sinks | grep "Name: $1" -A1 | tail -1 | cut -f2- -d' '
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
    pactl set-default-sink $TARGET_SINK

    SINK_INPUTS=(`sink_input_ids`)
    for i in "${SINK_INPUTS[@]}"; do
        pactl move-sink-input $i $TARGET_SINK
    done

    notify-send "Switch audio output to “`pretty_name $TARGET_SINK`”"\
        -i audio-card
}

case "$1" in
    up)
        pactl set-sink-volume `default_sink` +5%
        ;;
    down)
        pactl set-sink-volume `default_sink` -5%
        ;;
    mute)
        pactl set-sink-mute `default_sink` toggle
        ;;
    toggle)
        toggle_default_sink_and_move_inputs
        ;;
    *)
        echo "Usage: $0 {up|down|mute|toggle}"
        exit 2
esac
