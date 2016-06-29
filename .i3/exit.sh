#!/bin/sh

lock() {
    #gnome-screensaver-command -l
    ~/.i3/pixel_screenshot_lock.sh
}

killapps() {
    i3-msg '[class=".*"] kill' # close all windows
    while pgrep -f '/usr/bin/anki'; do sleep '0.1'; done # wait for anki to sync
    HOSTNAME=`hostname`
    while [ `xlsclients | grep -vE "^$HOSTNAME\s*(ibus-x11|unity-settings-daemon|notify-osd|gnome-screensaver|mozc_renderer)?\s*$" | wc -l` -gt 0 ]; do sleep '0.1'; done
    return 0
}

my_shutdown() {
    killapps
    /usr/bin/dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Stop
}

my_reboot() {
    killapps
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
    suspend)
        lock; my_suspend
        ;;
    reboot)
        my_reboot
        ;;
    shutdown)
        my_shutdown
        ;;
    *)
        echo "Usage: $0 {lock|logout|suspend|reboot|shutdown}"
        exit 2
esac

exit 0
