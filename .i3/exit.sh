#!/bin/bash


THIS="`dirname $0`/$0" # path to script
# X clients that should be ignored
WHITELIST=(ibus-x11 ibus-ui-gtk3 unity-settings-daemon notify-osd \
    gnome-screensaver mozc_renderer redshift-gtk) 
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
                if [ "$CLIENT" = "$IGNORED" ]; then continue 2; fi
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
            -b 'Shutdown' "/bin/bash $THIS shutdown_force" \
            -b 'Reboot' "/bin/bash $THIS reboot_force" &
    fi
    while [ `countclients` -gt 0 ]; do sleep '0.1'; done
    return 0
}

my_shutdown() {
    /usr/bin/dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Stop
}

my_reboot() {
    /usr/bin/dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Restart
}

my_suspend() {
    /usr/bin/dbus-send --system --print-reply --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Suspend
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
    reboot)
        killapps; my_reboot
        ;;
    reboot_force)
        my_reboot
        ;;
    shutdown)
        killapps; my_shutdown
        ;;
    shutdown_force)
        my_shutdown
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
