function output -d 'tail the stdout/stderr fds of a process matched by name'
    if test (count $argv) -eq 0
        echo 'output: expected a process name' >&2
        return 1
    end
    set -l pid (pgrep "$argv[1]")
    if test -z "$pid"
        echo 'output: process not found' >&2
        return 1
    end
    tail -f "/proc/$pid/fd/1" "/proc/$pid/fd/2"
end
