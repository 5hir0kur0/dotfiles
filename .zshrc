# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=4200
SAVEHIST=4200
bindkey -v #vi mode
#make backwards search work like in emacs mode
bindkey '^r' history-incremental-search-backward 
#enable backwards search by typing / in NORMAL mode
bindkey -M vicmd '/' history-incremental-search-backward
#zstyle :compinstall filename '~/.zshrc'

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

alias grep='grep --color=auto'

alias thx="echo You\'re welcome"
alias die="kill -9"
alias wipe_out="sudo killall"
alias update='sudo pacman -Syy && sudo pacman -Syu'

alias g++="g++ -Wall -Wextra -std=c++11"
alias gcc="gcc -Wall -Wextra -std=c99"

function rmbackups() {
    rm ./*~;
}

function rmbackups_hidden() {
    rm ./.*~;
}

function f() {
    find . -maxdepth 1 -iname "*$1*";
}

function ff() {
    find . -iname "*$1*";
}

function fancy_unixtime() {
     while true; do
         figlet -tc $(date +%s)
         sleep 1
         echo -n "\x1B[2J\x1B[0;0H"; #clear screen and move cursor to 0,0
    done
}

#make ctrl - left/right arrow work like in bash
bindkey ';5D' emacs-backward-word
bindkey ';5C' emacs-forward-word

##set prompt, colors
autoload -U colors && colors
PROMPT="%{$fg[red]%}%(?..[%?])%{$fg[magenta]%}%n@%m%{$fg[white]%}:%{$fg[cyan]%}%1~ %# %{$reset_color%}"
# RPROMPT="[%{$fg_no_bold[yellow]%}%?%{$reset_color%}]"

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
