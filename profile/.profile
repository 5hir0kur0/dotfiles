export PATH="$HOME/.local/bin:$HOME/.local/share/scripts:""$PATH"

export EDITOR=nvim

export RANGER_LOAD_DEFAULT_RC=FALSE

export BUILDDIR=/tmp/.build-$USER

# experiment
export MANPAGER="nvim -c 'set ft=man nonumber nolist ts=8 laststatus=1 showtabline=1' -"

MY_ETHERNET=$(find /sys/class/net -name 'enp*' -print0 -name 'eth*' -print0 2>/dev/null | xargs -rL1 -0 basename | head -1)
export MY_ETHERNET

MY_WLAN=$(find /sys/class/net -name 'wlp*' -print0 -name 'wlan*' -print0 2>/dev/null | xargs -rL1 -0 basename | head -1)
export MY_WLAN


export MY_PROFILE_SOURCED=1

# bash uses $HOSTNAME and zsh uses $HOST
[ -f "$HOME/.profile-${HOSTNAME:-$HOST}" ] && source "$HOME/.profile-${HOSTNAME:-$HOST}"
