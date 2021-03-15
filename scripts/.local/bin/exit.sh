#!/bin/bash

set -u

# requires: wmctrl, xdotool

LOCK_SCRIPT=~/.local/bin/blurred_screenshot_lock.sh
KILL_SCRIPT=~/.local/bin/kill.sh
NAGSCRIPT=~/.local/bin/rofinag.sh
PULSESCRIPT=~/.local/bin/pulse.sh
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
        RES="$RES"", “$S”"
    done
    echo "${RES#, }"
}

list_windows() {
    wmctrl -l | tr -s ' ' | cut -d' ' -f4-
}

pretty_windows() {
    readarray -t WINDOWS < <(list_windows)
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
    # are there clients that refuse to die?
    if [ "$(count_windows)" -gt 0 ]; then
        case "$WINDOW_MANAGER" in
            i3)
                i3-nagbar -t warning \
                    -m "Some clients refused to close: $(pretty_windows)" \
                    -b 'Logout' "$0 logout_force" \
                    -b 'Shutdown' "$0 shutdown_force" \
                    -b 'Reboot' "$0 reboot_force" &
                ;;
            *)
                ( echo -e 'logout\nshutdown\nreboot' | $NAGSCRIPT \
                     "Some clients refused to close: $(pretty_windows)" \
                     "$0 logout_force" \
                     "$0 shutdown_force" \
                     "$0 reboot_force" ) &
                ;;
        esac
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
        case "$WINDOW_MANAGER" in
            i3)
                i3-nagbar -t warning -m "Could not shut down: $ERROR" \
                    -b 'Force shutdown' "$0 shutdown_force"
                ;;
            *)
                pkill -x rofi
                ( echo 'force shutdown' | $NAGSCRIPT \
                    "Could not shut down: $ERROR" \
                    "$0 shutdown_force" ) &
                ;;
        esac
    fi
}

my_reboot() {
    ERROR="$(systemctl reboot)"
    if [ "$?" -ne 0 ]; then
        case "$WINDOW_MANAGER" in
            i3)
                i3-nagbar -t warning -m "Could not reboot: $ERROR" \
                    -b 'Force reboot' "$0 reboot_force"
                ;;
            *)
                pkill -x rofi
                ( echo 'force reboot' | $NAGSCRIPT \
                    "Could not reboot: $ERROR" \
                    "$0 reboot_force" ) &
                ;;
        esac
    fi
}

my_suspend() {
    ERROR="$(systemctl suspend)"
    if [ "$?" -ne 0 ]; then
        case "$WINDOW_MANAGER" in
            i3)
                i3-nagbar -t error -m "Could not suspend: $ERROR"
                ;;
            *)
                pkill -x rofi
                rofi -e "Could not suspend: $ERROR"
                ;;
        esac
    fi
}

my_hybrid_sleep() {
    ERROR="$(systemctl hybrid-sleep)"
    if [ "$?" -ne 0 ]; then
        case "$WINDOW_MANAGER" in
            i3)
                i3-nagbar -t error -m "Could not enter hybrid sleep: $ERROR"
                ;;
            *)
                pkill -x rofi
                rofi -e "Could not enter hybrid sleep: $ERROR"
                ;;
        esac
    fi
}

my_hibernate() {
    ERROR="$(systemctl hibernate)"
    if [ "$?" -ne 0 ]; then
        case "$WINDOW_MANAGER" in
            i3)
                i3-nagbar -t error -m "Could not hibernate: $ERROR"
                ;;
            *)
                pkill -x rofi
                rofi -e "Could not hibernate: $ERROR"
                ;;
        esac
    fi
}

check_borg() {
    if pgrep -x borg; then
        notify-send -u critical 'borg is running; not shutting down'
        exit 1
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
        $PULSESCRIPT mute 1
        my_suspend
        ;;
    hybrid_sleep)
        $PULSESCRIPT mute 1
        my_hybrid_sleep
        ;;
    hibernate)
        $PULSESCRIPT mute 1
        my_hibernate
        ;;
# in the following cases the audio should only be muted, if the operatoin fails
    reboot)
        check_borg
        kill_apps; my_reboot
        $PULSESCRIPT mute 1
        ;;
    reboot_force)
        my_reboot
        $PULSESCRIPT mute 1
        ;;
    shutdown)
        check_borg
        kill_apps; my_shutdown
        $PULSESCRIPT mute 1
        ;;
    shutdown_force)
        my_shutdown
        $PULSESCRIPT mute 1
        ;;
    list_windows)
        list_windows
        ;;
    *)
        echo "Usage: $0 {lock|logout|suspend|reboot|shutdown|hybrid_sleep|hibernate}"
        exit 2
esac

exit 0
