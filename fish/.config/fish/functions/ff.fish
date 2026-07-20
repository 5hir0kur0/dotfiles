function ff -d 'find files recursively matching a pattern'
    if test (count $argv) -eq 0
        echo 'ff: expected a pattern' >&2
        return 1
    end
    find . -iname "*$argv[1]*"
end
