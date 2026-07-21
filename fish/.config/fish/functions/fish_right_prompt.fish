function __my_git_status -d 'compact git branch/dirty status, similar to zsh vcs_info formats'
    set -l branch (git symbolic-ref --short HEAD 2>/dev/null)
    if test -z "$branch"
        set branch (git rev-parse --short HEAD 2>/dev/null)
    end
    test -z "$branch"; and return

    set -l unstaged ''
    git diff --no-ext-diff --quiet 2>/dev/null; or set unstaged (set_color --bold magenta)

    echo -n (set_color blue)'['(set_color cyan)"$unstaged$branch"(set_color normal)(set_color blue)']'(set_color normal)
end

function fish_right_prompt
    # transient prompt (see fish_transient_prompt in config.fish): drop the
    # rprompt entirely from the version pushed into scrollback, matching
    # zsh's transientrprompt
    test "$argv[1]" = --final-rendering; and return

    set -l runtime_display ''
    if test -n "$CMD_DURATION"; and test "$CMD_DURATION" -gt 10000
        set runtime_display ' '(set_color cyan)'['(__my_displaytime (math "$CMD_DURATION / 1000"))']'(set_color normal)
    end

    set -l git_display (__my_git_status)
    test -n "$git_display"; and set git_display " $git_display"

    echo -n (set_color --dim)'~'"$USER"(set_color normal)"$runtime_display$git_display"
end
