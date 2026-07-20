function tail_ccze -d 'tail -f a log file through ccze'
    if test (count $argv) -eq 0
        echo 'tail_ccze: expected file name(s)' >&2
        return 1
    end
    tail --retry --follow=name $argv | ccze --raw-ansi
end
