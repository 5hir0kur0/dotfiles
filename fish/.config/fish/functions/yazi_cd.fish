function yazi_cd -d 'run yazi and cd to its last directory on exit'
    set -l tmp (mktemp)
    # `command` is needed in case `yazi_cd` is aliased to `yazi`
    command yazi --cwd-file="$tmp" $argv
    if test -f "$tmp"
        set -l dir (cat "$tmp")
        command rm -f "$tmp"
        if test -d "$dir"; and test "$dir" != (pwd)
            cd "$dir"; or return 1
        end
    end
    echo -e "\e[6 q" # set cursor back to line
end
