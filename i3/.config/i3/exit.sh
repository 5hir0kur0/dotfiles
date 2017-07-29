#!/bin/bash

set -u

# requires: wmctrl, xdotool

LOCK_SCRIPT=~/.config/i3/pixel_screenshot_lock.sh
KILL_SCRIPT=~/.config/i3/kill.sh
LC_ALL=C

lock() {
    $LOCK_SCRIPT
}

determine_wm() {
    wmctrl -m | grep 'Name:' | cut -d' ' -f2- 
}

WINDOW_MANAGER=$(determine_wm)

print_pretty() {
    RES=
    for S in "$@"; do
        RES="$RES"", “$(xargs <<< "$S")”" # xargs trims whitespace here...
    done
    echo "${RES#, }"
}

list_windows() {
    wmctrl -l | tr -s ' ' | cut -d' ' -f4-
}

pretty_windows() {
    readarray WINDOWS < <(list_windows)
    print_pretty "${WINDOWS[@]}"
}

list_window_ids() {
    wmctrl -l | cut -f1 -d' '
}

kill_all_windows() {
    WINDOWS=( $(list_window_ids) )
    for WINDOW in "${WINDOWS[@]}"; do
        kill_client "$WINDOW"
    done
}

list_all_client_ids() {
    xdotool search --any --class --name --classname ''
}

kill_all_clients() {
    CLIENTS=( $(list_all_client_ids) )
    for CLIENT in "${CLIENTS[@]}"; do
        kill_client "$CLIENT"
    done
}

kill_client() {
    wmctrl -i -c "${1:?}"
}

count_windows() {
    list_windows | wc -l
}

kill_apps() {
    kill_all_windows
    sleep 0.2 # arbitrary value...
    kill_all_clients
    if [[ "$(count_windows)" -gt 0 ]]; then # there are clients that refuse to die
        i3-nagbar -t warning \
            -m "Some clients refus to close: $(pretty_windows)" \
            -b 'Logout' "$0 logout_force" \
            -b 'Shutdown' "$0 shutdown_force" \
            -b 'Reboot' "$0 reboot_force" &
    fi
    while [ "$(count_windows)" -gt 0 ]; do sleep 0.2; done
    $KILL_SCRIPT
    return 0
}

my_logout() {
    case "$WINDOW_MANAGER" in
        i3)
            if hash i3-msg; then
                i3-msg exit
            else
                echo 'i3-msg not available' >&2
                exit 1
            fi
            ;;
        bspwm)
            if hash bspc; then
                bspc quit
            else
                echo 'bspc not available' >&2
                exit 1

            fi
            ;;
        *)
            echo 'unknown window manager:' "$WINDOW_MANAGER" >&2
            exit 1
    esac
}

my_shutdown() {
    ERROR="$(systemctl poweroff)"
    if [ "$?" -ne 0 ]; then
        i3-nagbar -t warning -m "Could not shut down: $ERROR" \
            -b 'Force Shutdown' "$0 shutdown_force"
    fi
}

my_reboot() {
    ERROR="$(systemctl reboot)"
    if [ "$?" -ne 0 ]; then
        i3-nagbar -t warning -m "Could not reboot: $ERROR" \
            -b 'Force Reboot' "$0 reboot_force"
    fi
}

my_suspend() {
    ERROR="$(systemctl suspend)"
    if [ "$?" -ne 0 ]; then
        i3-nagbar -t error -m "Could not suspend: $ERROR"
    fi
}

my_hybrid_sleep() {
    ERROR="$(systemctl hybrid-sleep)"
    if [ "$?" -ne 0 ]; then
        i3-nagbar -t error -m "Could not enter hybrid sleep: $ERROR"
    fi
}

case "$1" in
    lock)
        lock
        ;;
    logout)
        kill_apps; my_logout
        ;;
    logout_force)
        my_logout
        ;;
    suspend)
        lock; my_suspend
        ;;
    hybrid_sleep)
        lock; my_hybrid_sleep
        ;;
    reboot)
        kill_apps; my_reboot
        ;;
    reboot_force)
        my_reboot
        ;;
    shutdown)
        kill_apps; my_shutdown
        ;;
    shutdown_force)
        my_shutdown
        ;;
    list_windows)
        list_windows
        ;;
    *)
        echo "Usage: $0 {lock|logout|suspend|reboot|shutdown}"
        exit 2
esac

exit 0
