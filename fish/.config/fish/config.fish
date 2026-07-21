status is-interactive; or exit

## history

# fish already: incrementally appends history, dedups automatically, has no
# fixed size cap (unlike zsh's HISTSIZE/SAVEHIST), and ignores commands
# prefixed with a space (equivalent of zsh's `hist_ignore_space`). Nothing to
# configure here.

# don't beep
set -g fish_greeting

## prompt

# clear the rprompt once a command is submitted (zsh: transientrprompt),
# so scrollback stays free of redundant rprompts and is easy to copy-paste
set -g fish_transient_prompt 1

## fzf (ctrl-t file search, ctrl-r history search; alt-c intentionally unbound)

if command -q fzf
    set -gx FZF_DEFAULT_OPTS "--height 42% --border --reverse --cycle --info=inline"
    set -gx FZF_CTRL_T_OPTS "--preview='bat --color=always --wrap=never --style=plain,changes {}'"
    set -gx FZF_CTRL_R_OPTS '--exact'
    fzf_key_bindings
    # undo the alt-c (cd) binding; only want ctrl-t and ctrl-r
    bind --erase \ec 2>/dev/null
    bind -M insert --erase \ec 2>/dev/null
end

## zoxide

if command -q zoxide
    zoxide init fish | source
    alias j=z
end

## auto ls after cd

function __my_cd_ls --on-variable PWD --description 'list directory contents after cd'
    status --is-command-substitution; and return
    __my_cd_fun
end

## aliases / functions

# (functions in ./functions/ are autoloaded by fish; nothing to source here)
