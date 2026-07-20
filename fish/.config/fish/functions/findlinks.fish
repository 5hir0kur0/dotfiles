function findlinks -d 'find any link (soft or hard) pointing to a given file, following symlinks while searching'
    if test (count $argv) -lt 2
        echo 'findlinks: expected start dir and file name' >&2
        return 1
    end
    find -L "$argv[1]" -samefile "$argv[2]" 2>/dev/null
end
