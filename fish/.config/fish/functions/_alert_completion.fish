function _alert_completion -d 'run a command and notify-send when it finishes (usually via alert_completion aliases)'
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
    set -l time_str (__my_displaytime (math (date +%s) - $start))
    _notify_send "$notify_arg" "Task $how in $time_str" "$argv"
end
