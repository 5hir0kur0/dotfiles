function __my_prompt_width -d 'target width for the shortened pwd, ~32% of terminal width'
    echo (math -s0 "$COLUMNS * 32 / 100")
end

function __my_fit_path -d 'shorten path elements (except first/last) to fit a target width'
    set -l path $argv[1]
    set -l desired_length $argv[2]

    set -l elements (string split '/' -- $path)
    # string split on a leading '/' produces a leading empty element already,
    # e.g. "/foo/bar" -> '' foo bar ; "~/foo" -> '~' foo (no leading empty)
    if test (count $elements) -eq 0
        echo $path
        return
    end

    set -l n (count $elements)
    for i in (seq 2 (math $n - 1))
        set -l current (string join '/' -- $elements)
        if test (string length -- $current) -le $desired_length
            echo $current
            return
        end
        set elements[$i] (string sub -l 1 -- $elements[$i])
    end
    string join '/' -- $elements
end

function __my_pwd_display -d 'home-relative pwd, shortened to fit the terminal width'
    set -l pwd_display (string replace -r '^'"$HOME"'($|/)' '~$1' -- $PWD)
    set -l target (math -s0 (__my_prompt_width) - 2)
    test $target -lt 1; and set target 1
    if test (string length -- $pwd_display) -le (__my_prompt_width)
        __my_fit_path $pwd_display $target
    else
        set -l fitted (__my_fit_path $pwd_display $target)
        # emulate zsh's "%<…<" truncation from the left if still too long
        set -l max (__my_prompt_width)
        if test (string length -- $fitted) -gt $max
            set -l pos (math -s0 (string length -- $fitted) - $max + 2)
            test $pos -lt 1; and set pos 1
            echo …(string sub -s $pos -- $fitted)
        else
            echo $fitted
        end
    end
end

function fish_prompt
    set -l last_status $status

    set -l status_display ''
    if test $last_status -ne 0
        set status_display (set_color --bold red)"[$last_status] "(set_color normal)
    end

    set -l path_display (set_color cyan)(__my_pwd_display)(set_color normal)

    set -l prompt_char '%'
    fish_is_root_user; and set prompt_char '#'

    echo -n "$status_display$path_display $prompt_char "(set_color normal)
end
