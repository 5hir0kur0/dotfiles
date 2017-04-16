# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=42000
SAVEHIST=42000
# no duplicate entries in history
setopt histignoredups
setopt histsavenodups

bindkey -e #emacs mode
#make backwards search work like in emacs mode
bindkey '^r' history-incremental-search-backward 
#enable backwards search by typing / in NORMAL mode
bindkey -M vicmd '/' history-incremental-search-backward
#zstyle :compinstall filename '~/.zshrc'

#better c-p, c-n
bindkey "^P" up-line-or-search
bindkey "^N" down-line-or-search

#autojump
. /usr/share/autojump/autojump.zsh
export AUTOJUMP_IGNORE_CASE=1
#/autojump

autoload -Uz compinit
compinit


# use case-insensitive completion
#zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

##Own aliases
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -A'
alias lla='la -Alh'
alias l='ls -C'
alias '..'='cd ..'
alias '...'='cd ../..'
alias '....'='cd ../../..'
alias '.....'='cd ../../../..'
alias mv='mv -iv'
alias rm='rm -Iv --one-file-system'

alias grep='grep --color=auto'
alias diff='diff --color=auto'

alias less='less -FX'

alias hcat="highlight --force -O ansi"

alias update='sudo pacmatic -Syu'

alias g++="g++ -Wall -Wextra -std=c++11"
alias gcc="gcc -Wall -Wextra -std=c99"

alias view="vim -R -c 'set nomodifiable'"

function f() {
    find . -maxdepth 1 -iname "*$1*";
}

function ff() {
    find . -iname "*$1*";
}

# launch quietly and disown
function lqd() {
    ( $@ ) >& /dev/null & disown
}

function output() {
    PID=`pgrep "$1"`
    tail -f "/proc/$PID/fd/1" "/proc/$PID/fd/2"
}

function fancy_unixtime() {
    OLDF=""
     while true; do
         SECS=`date +%s`
         BASE="${1-16}"
         NEWF="$(figlet -tc $(echo "obase=$BASE; $SECS" | bc))"
         if [ ! "$OLDF" = "$NEWF" ]; then
             echo -n "\x1B[2J\x1B[0;0H"; #clear screen and move cursor to 0,0
             echo "$NEWF"
             OLDF="$NEWF"
         fi
         sleep 0.1
    done
}

# go up n directories
# stolen from: https://www.reddit.com/r/ProgrammerHumor/comments/4f2o6l/typical_entrepreneurs/d25o3wu
function up() {
    cd $(eval printf '../'%.0s {1.."$1"})
}

##set prompt, colors
autoload -U colors && colors
# TODO: use abbreviated path like in fish, maybe remove username and put it into tmux
PROMPT="%{$fg[red]%}%(?..[%?])%{$fg[magenta]%}%n%{$fg[white]%}:%{$fg[cyan]%}%~ %# %{$reset_color%}"

##keybindings from archlinux.org
typeset -A key

key[Home]=${terminfo[khome]}

key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# setup key accordingly
[[ -n "${key[Home]}"     ]]  && bindkey  "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"      ]]  && bindkey  "${key[End]}"      end-of-line
[[ -n "${key[Insert]}"   ]]  && bindkey  "${key[Insert]}"   overwrite-mode
[[ -n "${key[Delete]}"   ]]  && bindkey  "${key[Delete]}"   delete-char
[[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       up-line-or-history
[[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     down-line-or-history
[[ -n "${key[Left]}"     ]]  && bindkey  "${key[Left]}"     backward-char
[[ -n "${key[Right]}"    ]]  && bindkey  "${key[Right]}"    forward-char
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"   beginning-of-buffer-or-history
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" end-of-buffer-or-history

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init () {
        printf '%s' "${terminfo[smkx]}"
    }
    function zle-line-finish () {
        printf '%s' "${terminfo[rmkx]}"
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi

[[ -f ~/.profile ]] && . ~/.profile

# use syntax highlighting (needs community/zsh-syntax-highlighting)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# cd automatically when typing just the directory name (e.g. "$ /tmp<CR>"
setopt autocd
# automatically push directories onto the "dirs" stack on cd
setopt autopushd
# don't push duplicate directories
setopt pushdignoredups
# delete rprompt when accepting a command (when enter is pressed)
setopt transientrprompt
# remove rprompt indent
ZLE_RPROMPT_INDENT=0

# stolen from http://stackoverflow.com/a/1128583
setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats \
    '%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f'
zstyle ':vcs_info:*' formats       \
    '%F{5}[%F{2}%b%F{5}]%f'

zstyle ':vcs_info:*' enable git

# or use pre_cmd, see man zshcontrib
prompt_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
  fi
}
RPROMPT=$'$(prompt_wrapper)'
