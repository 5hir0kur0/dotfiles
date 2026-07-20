function strace-fancy -d 'strace with a fuller flag set, logging to a file'
    if test (count $argv) -lt 2
        echo 'strace-fancy: expected log file name and path to binary' >&2
        return 1
    end
    command strace -ftrCDTYyy -o "$argv[1]" -v -s128 "$argv[2]"
end
