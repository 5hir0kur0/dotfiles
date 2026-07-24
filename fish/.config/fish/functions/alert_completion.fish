function _my_notify_send -d 'make notify-send work across users/sessions (e.g. when run as root); $argv[1] is --all or a uid'
    if test (count $argv) -eq 0
        echo '_my_notify_send: expected --all or a uid' >&2
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

function alert_completion -d 'run a command and notify-send when it finishes (usually via alert_completion aliases)'
    set -l start (date +%s)
    set -l notify_arg --all
    if test "$argv[1]" = --only-me
        set -e argv[1]
        set notify_arg (id --user)
    end
    set -l how
    if $argv
        set how completed
    else
        set how failed
    end
    echo -ne '\a' # bell for tmux
    set -l time_str (_my_displaytime (math (date +%s) - $start))
    _my_notify_send "$notify_arg" "Task $how in $time_str" "$argv"
end
