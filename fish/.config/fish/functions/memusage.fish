function memusage -d 'sum memory usage of all processes matching a name'
    if test (count $argv) -eq 0
        echo 'memusage: expected process name' >&2
        return 1
    end
    set -l parent_pid (pgrep -x "$argv[1]")
    set -l mode (test -n "$argv[2]"; and echo $argv[2]; or echo pss)
    memusage_pid "$parent_pid" "$mode"
end
