## options and variables

# history
HISTFILE=~/.histfile
HISTSIZE=420000
SAVEHIST=420000
# don't enter command in history if it's the same as the previous command
setopt histignoredups
setopt histsavenodups
# don't store invocations of the history command itself in the history
setopt histnostore
# remove unnecessary whitespace
setopt histreduceblanks
# use native locking for histfile
setopt hist_fcntl_lock

# sharing history
setopt sharehistory
# don't use the shared history for moving up/down in history
# (stolen from  https://superuser.com/a/691603)
up-line-or-local-history() {
    zle set-local-history 1
    zle up-line-or-history
    zle set-local-history 0
}
zle -N up-line-or-local-history
down-line-or-local-history() {
    zle set-local-history 1
    zle down-line-or-history
    zle set-local-history 0
}
zle -N down-line-or-local-history
up-line-or-local-search() {
    zle set-local-history 1
    zle up-line-or-search
    zle set-local-history 0
}
zle -N up-line-or-local-search
down-line-or-local-search() {
    zle set-local-history 1
    zle down-line-or-search
    zle set-local-history 0
}
zle -N down-line-or-local-search

# time reporting
# report how long a command took if it was longer than 5 seconds
REPORTTIME=10
# TODO count total time and put it in right prompt?
# time formatting for `time`
TIMEFMT=$'%J:\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P\nmax\t%MKiB'

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

# enable correction
setopt correct
# spelling correction prompt
SPROMPT="'%U%R%u' -> '%F{cyan}%B%r%f%b' [nyae]? "

setopt nobeep
setopt warncreateglobal

# disable annoying ctrl-s and ctrl-q commands
stty stop undef
stty start undef
unsetopt flowcontrol

## completion

# TODO do i like this?
setopt listpacked

# lay out completion lists horizontally
setopt listrowsfirst

# insert first match immediately
# setopt menucomplete

autoload -Uz compinit
compinit

# use case-insensitive completion
#zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

## key bindings

bindkey -e # emacs mode

# vi mode settings
#bindkey '^r' history-incremental-search-backward 
## enable backwards search by typing / in NORMAL mode
#bindkey -M vicmd '/' history-incremental-search-backward
##zstyle :compinstall filename '~/.zshrc'

#better c-p, c-n
bindkey "^P" up-line-or-local-search
bindkey "^N" down-line-or-local-search

# keybindings from archlinux.org
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
# {up,down}-line-or-local-history is defined above
[[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       up-line-or-local-history
[[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     down-line-or-local-history
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

## source files

[[ -f ~/.profile ]] && . ~/.profile

# use syntax highlighting (needs community/zsh-syntax-highlighting)
{source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh || source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh} 2>/dev/null


## prompt

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

##set prompt, colors
#autoload -U colors && colors
# TODO: use abbreviated path like in fish, maybe remove username and put it into tmux
PROMPT="%F{red}%(0?..[%?])%f%F{magenta}%n%f%F{white}:%f%F{cyan}%~ %# %f"


## fzf
export FZF_DEFAULT_OPTS='--height 42% --reverse --border --cycle --inline-info --border -1'
export FZF_CTRL_T_OPTS='--preview="bash /usr/share/doc/ranger/config/scope.sh {} $((COLS/2)) $((LINES/3)) $HOME/.thumbnails False"'
export FZF_CTRL_R_OPTS='-e'
{source /usr/share/fzf/key-bindings.zsh || source ~/misc/apps/fzf/shell/key-bindings.zsh} 2>/dev/null
fzf-locate-widget() {
  local selected
  if selected=$(locate / | grep -v '\.cache\|\.local' | fzf --preview="bash /usr/share/doc/ranger/config/scope.sh {} $((COLS/2)) $((LINES/3)) $HOME/.thumbnails False"); then
    if [ -z "$LBUFFER" -a -f "$selected" ]; then
      LBUFFER="rifle ""'$selected'"
    else
      LBUFFER="$LBUFFER""'$selected'"
    fi
  fi
  zle redisplay
}
zle -N fzf-locate-widget
# kind of useless; use c-t + enter instead
# bindkey '^J' fzf-cd-widget
bindkey '\ei' fzf-locate-widget
# /fzf
