function less_pipe -d 'follow a pipe with less, resumable with F'
    set -l tempfile (mktemp /tmp/.less_pipe.XXXX)
    set -l pipe_command $argv[1]
    fish -c "$pipe_command > $tempfile" &
    set -l subshell_pid $last_pid
    command less --RAW-CONTROL-CHARS --chop-long-lines -n +F -- $tempfile
    command kill -- -$subshell_pid
    command rm -v -- $tempfile
end
