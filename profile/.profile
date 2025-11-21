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

export EDITOR=helix
export VISUAL=helix

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

# Fix XDG mess
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export CARGO_HOME="$XDG_DATA_HOME"/cargo
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export NODE_REPL_HISTORY="$XDG_STATE_HOME"/node_repl_history
export NPM_CONFIG_INIT_MODULE="$XDG_CONFIG_HOME"/npm/config/npm-init.js
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME"/npm
export NPM_CONFIG_TMP="$XDG_RUNTIME_DIR"/npm
export PYTHON_HISTORY="$XDG_STATE_HOME"/python_history
export REDISCLI_HISTFILE="$XDG_STATE_HOME"/redis/rediscli_history
export R_HISTFILE="$XDG_STATE_HOME/R/history"
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export SQLITE_HISTORY="$XDG_CACHE_HOME"/sqlite_history
export TEXMFVAR="$XDG_CACHE_HOME"/texlive/texmf-var
export ZDOTDIR="$XDG_CONFIG_HOME"/zsh

# bash uses $HOSTNAME and zsh uses $HOST
[ -f "$HOME/.profile-${HOSTNAME:-$HOST}" ] && source "$HOME/.profile-${HOSTNAME:-$HOST}"
