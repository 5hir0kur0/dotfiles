function __my_cd_fun -d 'run ls after every cd, truncated if the listing is long'
    set -l ls_output (ls --color --format=across --width="$COLUMNS")
    if test (count $ls_output) -le 5
        printf '%s\n' $ls_output
    else
        printf '%s\n' $ls_output[1..5]
        echo -e (set_color --bold cyan)'[...]'(set_color normal)
    end
end
