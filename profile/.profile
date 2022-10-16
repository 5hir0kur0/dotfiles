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
    export PATH="$PATH:$HOME/.emacs.d/bin"
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
export MANPAGER="nvim -c 'set ft=man nonumber nolist ts=8 laststatus=1 showtabline=1' '+Man!' '+nnoremap q ZQ' -"

MY_ETHERNET=$(find /sys/class/net -name 'enp*' -print0 -name 'eth*' -print0 2>/dev/null | xargs -rL1 -0 basename | head -1)
export MY_ETHERNET

MY_WLAN=$(find /sys/class/net -name 'wlp*' -print0 -name 'wlan*' -print0 2>/dev/null | xargs -rL1 -0 basename | head -1)
export MY_WLAN

# SSH Agent


export SSH_AGENT_PID
export SSH_AUTH_SOCK

if [ -z "$SSH_AUTH_SOCK" ]; then
    SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$HOME/.ssh/.ssh-agent.sock}"
    SSH_AGENT_PID=$(pgrep -fx "(/usr/bin/)?ssh-agent.*$SSH_AUTH_SOCK")
    if [ "$?" -ne 0 ]; then
        rm -f "${SSH_AUTH_SOCK:?}"
        eval "$(ssh-agent -a "$SSH_AUTH_SOCK")"
    fi
elif [ -z "$SSH_AGENT_PID" ]; then
    SSH_AGENT_PID=$(pgrep -x ssh-agent | head -n 1)
fi

# Input Method
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=xim
export SDL_IM_MODULE=fcitx
export GLFW_IM_MODULE=ibus

# bash uses $HOSTNAME and zsh uses $HOST
[ -f "$HOME/.profile-${HOSTNAME:-$HOST}" ] && source "$HOME/.profile-${HOSTNAME:-$HOST}"

export MY_PROFILE_SOURCED=1
