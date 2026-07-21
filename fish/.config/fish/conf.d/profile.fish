## PATH additions (fish_add_path already dedups, so no guards needed)

## editor

if test "$TERM_PROGRAM" = vscode
    set -gx EDITOR "code --wait"
else
    set -gx EDITOR nvim
end
set -gx VISUAL $EDITOR

# custom scripts
fish_add_path -a $HOME/.local/bin

# rust
fish_add_path -a $HOME/.cargo/bin

# golang
set -gx GOPATH $HOME/code/go
fish_add_path -a $HOME/code/go/bin

# doom emacs
fish_add_path -a $HOME/.config/emacs/bin

fish_add_path -a $HOME/.local/share/cargo/bin

fish_add_path -a $HOME/.elan/bin

## misc env vars

set -gx LESS '--mouse --use-color --ignore-case --chop-long-lines --raw-control-chars --incsearch --LONG-PROMPT'

# build makepkg packages in /tmp (yields better performance because then
# they're built in RAM [I mount /tmp as tmpfs])
set -gx BUILDDIR /tmp/.build-$USER

# display man pages using neovim
set -gx MANPAGER "nvim '+Man!'"

## SSH Agent

if not set -q SSH_AUTH_SOCK; or not test -f "$SSH_AUTH_SOCK"
    set -gx SSH_AUTH_SOCK "$HOME/.ssh/.ssh-agent.sock"
    set -l pid (pgrep -x ssh-agent -u (id -u) | head -n 1)
    if test -z "$pid"
        rm -f "$SSH_AUTH_SOCK"
        eval (ssh-agent -c -a "$SSH_AUTH_SOCK")
    else
        set -gx SSH_AGENT_PID $pid
    end
else if not set -q SSH_AGENT_PID
    set -gx SSH_AGENT_PID (pgrep -x ssh-agent -u (id -u) | head -n 1)
end

# host-specific profile, if present
if test -f "$HOME/.profile-$hostname"
    source "$HOME/.profile-$hostname"
end
