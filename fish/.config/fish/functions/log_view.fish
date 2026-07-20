function log_view -d 'view a log file with colorized less'
    if test (count $argv) -eq 0
        echo 'log_view: expected file name(s)' >&2
        return 1
    end
    cat $argv | ccze --raw-ansi | less -rFXS
end
