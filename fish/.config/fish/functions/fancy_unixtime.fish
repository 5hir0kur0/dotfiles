function fancy_unixtime -d 'show the unix timestamp in giant ascii art, updated live'
    set -l oldf ''
    while true
        set -l secs (date +%s)
        set -l base (test -n "$argv[1]"; and echo $argv[1]; or echo X)
        set -l newf (figlet -W -f banner -tc (printf "%$base\n" "$secs"))
        if test "$oldf" != "$newf"
            printf '\x1B[2J\x1B[0;0H' # clear screen and move cursor to 0,0
            echo "$newf"
            set oldf $newf
        end
        sleep 0.1
    end
end
