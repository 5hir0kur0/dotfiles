function lcd -d 'cd into the directory a symlink actually points to (following the link)'
    if test (count $argv) -eq 0
        echo 'lcd: symlink unspecified' >&2
        return 1
    end
    if test -f "$argv[1]"
        cd (path dirname -- (readlink -f "$argv[1]"))
    else if test -d "$argv[1]"
        cd (readlink -f "$argv[1]")
    end
end
