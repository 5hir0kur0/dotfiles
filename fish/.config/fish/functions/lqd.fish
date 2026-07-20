function lqd -d 'launch quietly and disown'
    if test (count $argv) -eq 0
        echo 'lqd: expected a command' >&2
        return 1
    end
    $argv >/dev/null &
    disown
end
