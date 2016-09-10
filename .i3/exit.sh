#!/bin/bash

# X clients that should be ignored (treated as regex)
WHITELIST=(ibus-x11 ibus-ui-gtk3 unity-settings-daemon notify-osd \
    gnome-screensaver mozc_renderer redshift-gtk pasystray nm-applet \
    ^.*kwalletd$ kded4 kdeinit4)
HOSTNAME=`hostname`

lock() {
    ~/.i3/pixel_screenshot_lock.sh
}

# the ugliest implementation of join you have ever seen...
join_comma() {
    local IFS=','
    echo "$*" | sed 's/,/, /g'
}

listclients() {
    declare -ag CLIENTS
    CLIENTS=()
    local INDEX=0
    while read LINE; do
        local CLIENT=`echo $LINE | sed -rn 's/^\S+\s+(.+)$/\1/p'`
        if [ -n "$CLIENT" ]; then
            for IGNORED in "${WHITELIST[@]}"; do
                if [[ "$CLIENT" =~ $IGNORED ]]; then continue 2; fi
            done
            CLIENTS[$INDEX]="$CLIENT"
            INDEX=$((INDEX + 1))
        fi
    done < <(xlsclients) # the loop somehow can't modify the variables
                         # if I just pipe this in...
    join_comma "${CLIENTS[@]}"
}

countclients() {
    listclients >& /dev/null
    echo ${#CLIENTS[@]}
}

killapps() {
    i3-msg '[class=".*"] kill' # close all windows
    while pgrep -f '/usr/bin/anki'; do sleep '0.1'; done # wait for anki to sync
    if [ `countclients` -gt 0 ]; then # there are clients that refuse to die
        i3-nagbar -t warning \
            -m "The following clients refused to close: `listclients`" \
            -b 'Logout' 'i3-msg exit' \
            -b 'Shutdown' "$0 shutdown_force" \
            -b 'Reboot' "$0 reboot_force" &
    fi
    while [ `countclients` -gt 0 ]; do sleep '0.1'; done
    return 0
}

my_shutdown() {
    ERROR=`systemctl poweroff`
    if [ $? -ne 0 ]; then
        i3-nagbar -t warning -m "Could not shut down: $ERROR" \
            -b 'Force Shutdown' "$0 shutdown_force"
    fi
}

my_shutdown_force() {
    systemctl poweroff -i
}

my_reboot() {
    ERROR=`systemctl reboot`
    if [ $? -ne 0 ]; then
        i3-nagbar -t warning -m "Could not reboot: $ERROR" \
            -b 'Force Reboot' "$0 reboot_force"
    fi
}

my_reboot_force() {
    systemctl reboot -i
}

my_suspend() {
    ERROR=`systemctl suspend`
    if [ $? -ne 0 ]; then
        i3-nagbar -t error -m "Could not suspend: $ERROR"
    fi
}

my_hybrid_sleep() {
    ERROR=`systemctl hybrid-sleep`
    if [ $? -ne 0 ]; then
        i3-nagbar -t error -m "Could not enter hybrid sleep: $ERROR"
    fi
}

case "$1" in
    lock)
        lock
        ;;
    logout)
        killapps; i3-msg exit
        ;;
    logout_force)
        i3-msg exit
        ;;
    suspend)
        lock; my_suspend
        ;;
    hybrid_sleep)
        lock; my_hybrid_sleep
        ;;
    reboot)
        killapps; my_reboot
        ;;
    reboot_force)
        my_reboot_force
        ;;
    shutdown)
        killapps; my_shutdown
        ;;
    shutdown_force)
        my_shutdown_force
        ;;
    listclients)
        listclients
        ;;
    countclients)
        countclients
        ;;
    *)
        echo "Usage: $0 {lock|logout|suspend|reboot|shutdown}"
        exit 2
esac

exit 0
