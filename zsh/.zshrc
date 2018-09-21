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

# enable correction
setopt correct
# spelling correction prompt
SPROMPT="'%U%R%u' -> '%F{cyan}%B%r%f%b' [nyae]? "

# don't beep
setopt nobeep

# warn if shell functions create global variables
setopt warncreateglobal
# setopt warnnestedvar

# don't run background jobs at a lower priority
setopt nobgnice

# disable annoying ctrl-s and ctrl-q commands
stty stop undef
stty start undef
unsetopt flowcontrol

## completion

# more compact listing of completions
setopt listpacked

# lay out completion lists horizontally
setopt listrowsfirst

# insert first match immediately
setopt menucomplete

# complete at cursor position within a word instead of moving the cursor to the
# end when the tab key is pressed
setopt completeinword

# completion config (mainy generated using compinstall)
zstyle ':completion:*' verbose yes
zstyle ':completion:*' auto-description '<%d>'
zstyle ':completion:*' completer _expand _complete _ignored _match _correct _approximate
# enable colored completions using the default colors
# (for some reason the directory color didn't match ls)
zstyle ':completion:*' list-colors 'di=1;34'
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
# first try without a matcher, then try with smartcase matching (lowercase
# matches uppercase), then try substring matching, then try partial-word matching
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' '+l:|=* r:|=*' '+r:|[._-]=** r:|=**'
# use the selection (with highlighting and cursorkey navigation) only if there
# are at least 6 items (useful because otherwise you always have to press enter
# two times to execute the command)
zstyle ':completion:*' menu select=6
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

# ignore internal zsh functions
# (stolen from: https://github.com/solnic/dotfiles/blob/master/home/zsh/completion.zsh)
zstyle ':completion:*:functions' ignored-patterns '_*'

# better completion for commands that take pids (e.g. kill)
zstyle ':completion:*:processes' menu yes select
zstyle ':completion:*:processes' command 'ps -efm | grep -vE \]\$\|-\$'

# better completion for commands that take process names (e.g. killall)
# (stolen from: https://github.com/solnic/dotfiles/blob/master/home/zsh/completion.zsh)
zstyle ':completion:*:processes-names' command "ps -eo cmd= | sed 's:\([^ ]*\).*:\1:;s:/[^ ]*/::;/^\[/d'"

autoload -Uz compinit
compinit

# use c-n and c-p in the completion menu
# (the reason this doesn't work without those lines is probably that I rebound
# c-n and c-p)
zmodload zsh/complist
bindkey -M menuselect '^N' down-line-or-history
bindkey -M menuselect '^P' up-line-or-history


## key bindings

bindkey -e # emacs mode

# better c-p, c-n
bindkey '^P' up-line-or-local-search
bindkey '^N' down-line-or-local-search

# make M-DEL delete up to the last special character (e.g. / in paths)
# except '*?.~!$' are considered parts of words
backward-kill-to-special-char () {
    local WORDCHARS='*?.~!$'
    zle backward-kill-word
}
zle -N backward-kill-to-special-char
bindkey '^[^?' backward-kill-to-special-char

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

## syntax highlighting

# use syntax highlighting (needs community/zsh-syntax-highlighting)
{source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh || source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh} 2>/dev/null

## prompt

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
