function f -d 'find files in the current dir (non-recursive) matching a pattern'
    if test (count $argv) -eq 0
        echo 'f: expected a pattern' >&2
        return 1
    end
    find . -maxdepth 1 -iname "*$argv[1]*"
end
