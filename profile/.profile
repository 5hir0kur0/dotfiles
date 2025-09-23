if [ "$MY_PROFILE_SOURCED" = '1' ]; then
    return
fi

# custom scripts
if [[ "$PATH" != *"$HOME/.local/bin"* ]]; then
    export PATH="$PATH:$HOME/.local/bin"
fi

# rust
if [[ "$PATH" != *"$HOME/.cargo/bin"* ]]; then
    export PATH="$PATH:$HOME/.cargo/bin"
fi

# golang
export GOPATH="$HOME/code/go"
if [[ "$PATH" != *"$HOME/code/go/bin"* ]]; then
    export PATH="$PATH:$HOME/code/go/bin"
fi

# doom emacs
if [[ "$PATH" != *"$HOME/.emacs/bin"* ]]; then
    export PATH="$PATH:$HOME/.config/emacs/bin"
fi

export EDITOR=nvim
export VISUAL=nvim

export LESS='--mouse --use-color --ignore-case --chop-long-lines --raw-control-chars --incsearch --LONG-PROMPT'

# avoid loading the ranger default config only for it to be overwritten by my
# personal config
export RANGER_LOAD_DEFAULT_RC=FALSE

# build makepkg packages in /tmp (yields better performance because then
# they're built in RAM [I mount /tmp as tmpfs])
export BUILDDIR=/tmp/.build-$USER

# nicer output for bash -x
export PS4='+${LINENO}: '

# display man pages using neovim
export MANPAGER="nvim '+Man!'"

# SSH Agent

export SSH_AGENT_PID
export SSH_AUTH_SOCK

if [ -z "$SSH_AUTH_SOCK" ] || ! [ -f "$SSH_AUTH_SOCK" ]; then
    SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$HOME/.ssh/.ssh-agent.sock}"
    if ! SSH_AGENT_PID=$(pgrep -x ssh-agent -u "$(id -u)" | head -n 1); then
        rm -f "${SSH_AUTH_SOCK:?}"
        eval "$(ssh-agent -a "$SSH_AUTH_SOCK")"
    fi
elif [ -z "$SSH_AGENT_PID" ]; then
    SSH_AGENT_PID=$(pgrep -x ssh-agent -u "$(id -u)" | head -n 1)
fi

# bash uses $HOSTNAME and zsh uses $HOST
[ -f "$HOME/.profile-${HOSTNAME:-$HOST}" ] && source "$HOME/.profile-${HOSTNAME:-$HOST}"

export MY_PROFILE_SOURCED=1
