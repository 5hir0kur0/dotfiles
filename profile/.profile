if [ "$MY_PROFILE_SOURCED" = '1' ]; then
    return
fi

# custom scripts
if [[ "$PATH" != *"$HOME/.local/bin"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# rust
if [[ "$PATH" != *"$HOME/.cargo/bin"* ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# doom emacs
if [[ "$PATH" != *"$HOME/.emacs/bin"* ]]; then
    export PATH="$HOME/.emacs.d/bin:$PATH"
fi

export EDITOR=nvim
export VISUAL=nvim

# avoid loading the ranger default config only for it to be overwritten by my
# personal config
export RANGER_LOAD_DEFAULT_RC=FALSE

# build makepkg packages in /tmp (yields better performance because then
# they're built in RAM [I mount /tmp as tmpfs])
export BUILDDIR=/tmp/.build-$USER

# nicer output for bash -x
export PS4='+${LINENO}: '

# display man pages using neovim
export MANPAGER="nvim -c 'set ft=man nonumber nolist ts=8 laststatus=1 showtabline=1' -"

MY_ETHERNET=$(find /sys/class/net -name 'enp*' -print0 -name 'eth*' -print0 2>/dev/null | xargs -rL1 -0 basename | head -1)
export MY_ETHERNET

MY_WLAN=$(find /sys/class/net -name 'wlp*' -print0 -name 'wlan*' -print0 2>/dev/null | xargs -rL1 -0 basename | head -1)
export MY_WLAN

# bash uses $HOSTNAME and zsh uses $HOST
[ -f "$HOME/.profile-${HOSTNAME:-$HOST}" ] && source "$HOME/.profile-${HOSTNAME:-$HOST}"

export MY_PROFILE_SOURCED=1
