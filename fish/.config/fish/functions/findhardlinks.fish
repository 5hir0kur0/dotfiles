function findhardlinks -d 'find hard links pointing to a given file'
    if test (count $argv) -lt 2
        echo 'findhardlinks: expected start dir and file name' >&2
        return 1
    end
    find "$argv[1]" -samefile "$argv[2]" 2>/dev/null
end
