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
# ignore commands or aliases starting with a space
setopt hist_ignore_space

# don't save some commands in the history file
history_ignore=(
    '* --help'
    '?'
    '??'
    '..*'

    'j *'
    'k *'
    'vv *'

    'l *'
    'ls *'
    'lsd *'
    'lr *'
    'lrr *'
    'la *'
    'lla *'

    'git add *'
    'git a *'
    'g add *'
    'g a *'

    'svn add *'

    'git commit *'
    'git c *'
    'g c *'

    'grep *'
    'pgrep *'
    'ag *'
    'rg *'
    'gg *'
    'gpdf *'

    'ff *'
    'fd *'

    'latexmk *'
    'lpdf *'
    'llpdf *'

    'pass *'

    'lqd *'
    'lqqd *'

    'v *'
    'vim *'
    'sudoedit *'
)
HISTORY_IGNORE="(${(j.|.)history_ignore})"


# emacs mode (use emacs-style keybindings)
bindkey -e

# time reporting
# report how long a command took if it was longer than a certain amount of cpu time
REPORTTIME=20
# TODO count total time and put it in right prompt?
# time formatting for `time`
TIMEFMT=$'%J:\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P\nmax\t%MKiB'

# directory handling

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

# handle multi-byte characters
setopt multibyte

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
zstyle ':completion:*' completer _expand _complete _match _correct _approximate _ignored
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

zmodload zsh/complist
# make shift-tab go to the previous completion
bindkey -M menuselect '^[[Z' reverse-menu-complete

# first try to expand wildcards then try completion
bindkey '^I' expand-or-complete

## key bindings

# edit command line in $EDITOR (from http://distrustsimplicity.net/articles/zsh-command-editing/)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

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

## source files

# avoid sourcing .profile multiple times since some computations (might)
# take place there
[[ -f ~/.profile ]] && [[ -z "$MY_PROFILE_SOURCED" ]] && source ~/.profile

## syntax highlighting

# use syntax highlighting (needs community/zsh-syntax-highlighting)
{source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh || source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh} 2>/dev/null

## prompt
setopt prompt_subst
#autoload -U colors && colors

# delete rprompt when accepting a command (when enter is pressed)
setopt transientrprompt
# remove rprompt indent
# (sadly, this seems to cause problems in some environments)
#ZLE_RPROMPT_INDENT=0

# stolen from http://stackoverflow.com/a/1128583
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git # svn
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' max-exports 1
zstyle ':vcs_info:*' stagedstr '%S'
zstyle ':vcs_info:*' unstagedstr "%B%F{yellow}"
zstyle ':vcs_info:*' branchformat '%b:%r'
zstyle ':vcs_info:*' actionformats \
    '%B%m%%b%f %F{blue}[%s%F{cyan}:%F{blue}%r%F{cyan}@%F{green}%c%u%b%f%%b%%s%F{cyan}|%f%B%%S%a%%s%%b%F{blue}]%f'
zstyle ':vcs_info:*' formats       \
    '%B%m%%b%f %F{blue}[%s%F{cyan}:%F{blue}%r%F{cyan}@%F{green}%c%u%b%f%%b%%s%F{blue}]%f'

# show the run time of the last command if it exceeds a certain length

export MY_CMD_RUNTIME=0
export MY_RUNTIME_DISYPAY=''

function preexec() {
    MY_CMD_RUNTIME=$SECONDS
}

# stolen from https://unix.stackexchange.com/a/27014
# parameters:
# 1: the time in seconds to be displayed in a more readable format
function displaytime {
    local T=$1
    local D=$((T/60/60/24))
    local H=$((T/60/60%24))
    local M=$((T/60%60))
    local S=$((T%60))
    float Df=$D
    float Y=$((Df/365))
    (( $D > 0 )) && printf '%dd ' $D
    (( $Y > 1 )) && printf '(~ %.1fy) ' $Y
    (( $H > 0 )) && printf '%dh ' $H
    (( $M > 0 )) && printf '%dm ' $M
    printf '%ds\n' $S
}

function precmd() {
    if [[ -n "$MY_CMD_RUNTIME" ]]; then
        MY_CMD_RUNTIME=$(( SECONDS - MY_CMD_RUNTIME ))
        if (( MY_CMD_RUNTIME > 10 )); then
            MY_RUNTIME_DISYPAY=" %F{cyan}[$(displaytime ${MY_CMD_RUNTIME})]%f"
        else
            MY_RUNTIME_DISYPAY=''
        fi
    fi
    MY_CMD_RUNTIME=''
}

# or use pre_cmd, see man zshcontrib
function prompt_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    echo "${vcs_info_msg_0_}%f"
  fi
}

#RPROMPT='%F{magenta}~%n%f$MY_RUNTIME_DISYPAY$(prompt_wrapper)'
RPROMPT='$(print "%{\e[2m%}~%n%{\e[22m%}")%f$MY_RUNTIME_DISYPAY$(prompt_wrapper)'

# helper function to shorten paths

# # shorten the elements of a path (except the last one) to the specified length
# # parameters:
# # 1: [optional] the path to shorten (default: print -P %~)
# # 2: [optional] the length of the shortened strings (default: 1 character)
# function _my_shorten_path() {
#     local path=${1:-$(print -P '%~')}
#     local elem_length=${2:-1}
#     local -a path_elements=(${(s./.)path})
#     local i
#     # if there are no path elements then we are in the root directory
#     if [[ -z $path_elements ]]; then
#         echo $path
#         return
#     fi
#     # append empty element so that a leading slash will be output
#     if [[ $path_elements[1] != ~* ]]; then
#         path_elements=('' ${path_elements[@]})
#     fi
#     # don't shorten the first and the last element
#     # (the first one is always going to be '' or '~[...]')
#     for ((i = 2; i < $#path_elements; i++)); do
#         path_elements[i]=${path_elements[i]:0:$elem_length}
#     done
#     # join elements with slashes
#     echo ${(j./.)path_elements}
# }

# # try to fit the given path into the specified length by reducing all elements
# # except the last one to a specified length (goes from trying longer lengths
# # to shorter ones)
# # parameters:
# # 1: [optional] path (default: print -P %~)
# # 2: [optional] desired length, default: $((COLUMNS/2))
# function _my_fit_path() {
#     local path=${1:-$(print -P '%~')}
#     local desired_length=${2:-$((COLUMNS/2))}
#     local length
#     # the length checking seems to only work for results of substitutions
#     # so it's easier to just substitute the path by "limiting" the element
#     # length to 1000 instead of using a separate if
#     for length in 1000 {10..2}; do
#         local new_path=$(_my_shorten_path $path $length)
#         if (( ${#new_path} <= desired_length )); then
#             echo $new_path
#             return
#         fi
#     done
#     _my_shorten_path $path
# }

# try to fit the given path into the specified length by reducing as many
# elements as necessary to be just one character long
# parameters:
# 1: [optional] path (default: print -P %~)
# 2: [optional] desired length, default: $((COLUMNS/2))
function _my_fit_path2() {
    local path=${1:-$(print -P '%~')}
    local -a path_elements=(${(s./.)path})
    local desired_length=${2:-$((COLUMNS/2))}
    local elem_length=1
    local i
    # if there are no path elements then we are in the root directory
    if [[ -z $path_elements ]]; then
        echo $path
        return
    fi
    # append empty element so that a leading slash will be output
    if [[ $path_elements[1] != ~* ]]; then
        path_elements=('' ${path_elements[@]})
    fi
    # don't shorten the first and the last element
    # (the first one is always going to be '' or '~[...]')
    for ((i = 2; i < $#path_elements; i++)); do
        local tmp_path=${(j./.)path_elements}
        # if the path is already shorter, there is no need to shorten the rest
        if (( $#tmp_path <= desired_length )); then
            echo $tmp_path
            return
        fi
        local shortened=${path_elements[i]:0:$elem_length}
        if [[ ${path_elements[i]} != $shortened ]]; then
            # path_elements[i]=$shortened…
            # don't indicate shortening after all
            path_elements[i]=$shortened
        else
            path_elements[i]=$shortened
        fi
    done
    # join elements with slashes
    echo ${(j./.)path_elements}
}

# PROMPT="%F{red}%(0?..[%?])%f%F{magenta}%n%f%F{white}:%f%F{cyan}%~ %# %f"

# make sure the prompt is never longer than about PROMPT_PERCENT_OF_LINE % of
# the available characters even if the last element of the path is longer than
# PROMPT_PERCENT_OF_LINE % of the line
# (stolen from https://unix.stackexchange.com/a/370276)
export PROMPT_PERCENT_OF_LINE=32
# make a function, so that it can be evaluated repeatedly
function _my_prompt_width() {
    echo $(( ${COLUMNS:-80} * PROMPT_PERCENT_OF_LINE / 100  ))
}

# can't pass pwd directly, because otherwise the percent expansion takes
# place after the command substitution
# (if the user is displayed in the prompt, maybe subtract ${#USER})
working_directory="\$(_my_fit_path2 '' \$((\$(_my_prompt_width) - 2)))"

wd_50_percent="%\$(_my_prompt_width)<…<$working_directory"

PROMPT="%B%F{red}%(0?..[%?] )%b%f%F{cyan}$wd_50_percent %# %f"

## fzf
export FZF_DEFAULT_OPTS="--height 42% --reverse --border --cycle --inline-info --border -1"
export FZF_CTRL_T_OPTS="--preview='bash $HOME/.local/bin/preview.sh {}'"
export FZF_CTRL_R_OPTS='-e'
{source /usr/share/fzf/key-bindings.zsh || source ~/misc/apps/fzf/shell/key-bindings.zsh} 2>/dev/null
function fzf-locate-widget() {
  local selected
  if selected=$(locate / | grep -v '\.cache\|\.local' | FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" fzf); then
    if [ -z "$LBUFFER" -a -f "$selected" ]; then
      LBUFFER="rifle ""'$selected'"
    else
      LBUFFER="$LBUFFER""'$selected'"
    fi
  fi
  zle redisplay
}
zle -N fzf-locate-widget
function fzf-cd-widget () {
    local cmd="command find -L . -mindepth 1 \\( -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune -o \\( -type d -o -type f \\) -print 2> /dev/null | cut -b3-"
    setopt localoptions pipefail 2> /dev/null
    local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS $FZF_CTRL_T_OPTS" fzf +m)"
    if [[ -z "$dir" ]]
    then
        zle redisplay
        return 0
    fi
    if [[ -d "$dir" ]]; then
        cd "$dir"
    elif [[ -f "$dir" ]]; then
        cd "${dir%/*}"
    else
        echo "fzf-cd: neither a file nor a directory: $dir" 1>&2
        return 1
    fi
    local ret=$?
    zle fzf-redraw-prompt
    return $ret
}
zle -N fzf-cd-widget
bindkey '^T' fzf-cd-widget
bindkey '\ei' fzf-locate-widget
# /fzf

[ -f "$HOME/.zsh_aliases" ] && source "$HOME/.zsh_aliases"
