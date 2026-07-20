function _notify_send -d 'make notify-send work across users/sessions (e.g. when run as root); $argv[1] is --all or a uid'
    if test (count $argv) -eq 0
        echo '_notify_send: expected --all or a uid' >&2
        return 1
    end
    set -l bus_paths
    if test "$argv[1]" = --all
        set bus_paths /run/user/*/bus
    else
        set bus_paths "/run/user/$argv[1]/bus"
    end
    set -e argv[1]
    for bus in $bus_paths
        set -l extracted_uid (string replace -r '.*/user/' '' -- $bus)
        set extracted_uid (string replace -r '/bus.*' '' -- $extracted_uid)
        sudo -u "#$extracted_uid" env DBUS_SESSION_BUS_ADDRESS="unix:path=$bus" notify-send $argv
    end
end
