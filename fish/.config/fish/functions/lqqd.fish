function lqqd -d 'launch quietly (stdout+stderr) and disown'
    if test (count $argv) -eq 0
        echo 'lqqd: expected a command' >&2
        return 1
    end
    $argv >/dev/null 2>&1 &
    disown
end
