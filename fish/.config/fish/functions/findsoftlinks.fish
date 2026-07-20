function findsoftlinks -d 'find soft links pointing to a given file'
    if test (count $argv) -lt 2
        echo 'findsoftlinks: expected start dir and file name' >&2
        return 1
    end
    find -L "$argv[1]" -xtype l -samefile "$argv[2]" 2>/dev/null
end
