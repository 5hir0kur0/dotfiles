# System-wide .bashrc file for interactive bash(1) shells.

# To enable the settings / commands in this file for login shells as well,
# this file has to be sourced in /etc/profile.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi


#------------------------------------------------------------------------------
# Returncode.
#------------------------------------------------------------------------------
function returncode
{
  returncode=$?
  if [ $returncode != 0 ]; then
    echo "[$returncode]"
  else
    echo ""
  fi
}



# set a fancy prompt (non-color, overwrite the one in /etc/profile)
#PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
        && type -P dircolors >/dev/null \
        && match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true


if ${use_color} ; then

        # enable color support of ls and also add handy aliases
        if [ -x /usr/bin/dircolors ]; then
        # test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        eval `dircolors`
        LS_COLORS="$LS_COLORS*.JPG=01;35:*.GIF=01;35:*.jpg=01;35:*.gif=01;35:*.jpeg=01;35:*.pcx=01;35:*.png=01;35:*.pnm=01;35:*.bz2=01;31:*.mpg=01;38:*.mpeg=01;38:*.MPG=01;38:*.MPEG=01;38:*.m4v=01;038:*.mp4=01;038:*.swf=01;038:*.avi=01;38:*.AVI=01;38:*.wmv=01;38:*.WMV=01;38:*.asf=01;38:*.ASF=01;38:*.mov=01;38:*.MOV=01;38:*.mp3=01;39:*.ogg=01;39:*.MP3=01;39:*.Mp3=01;39"
        fi
        # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
        #if type -P dircolors >/dev/null ; then
        #        if [[ -f ~/.dir_colors ]] ; then
        #                eval $(dircolors -b ~/.dir_colors)
        #        elif [[ -f /etc/DIR_COLORS ]] ; then
        #                eval $(dircolors -b /etc/DIR_COLORS)
        #        fi
        #fi

        if [[ ${EUID} == 0 ]] ; then
                PS1='\[\033[0;31m\]$(returncode)\[\033[0;37m\]\[\033[0;35m\]${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
        else
                PS1='\[\033[0;31m\]$(returncode)\[\033[0;37m\]\[\033[0;35m\]${debian_chroot:+($debian_chroot)}\[\033[0;35m\]\u@\h\[\033[0;37m\]:\[\033[0;36m\]\W $\[\033[0;00m\] '
        fi

        alias ls='ls --color=auto'
        alias grep='grep --colour=auto'
        alias fgrep='fgrep --colour=auto'
        alias egrep='egrep --colour=auto'
        alias ll='ls -lF'
        alias la='ls -A'
        alias l='ls -CF'
else
        if [[ ${EUID} == 0 ]] ; then
                # show root@ when we don't have colors
                PS1='\[$(returncode)\]\u@\h \W \$ '
        else
                PS1='\[$(returncode)\]\u@\h \w \$ '
        fi
fi

# Try to keep environment pollution down, EPA loves us.
unset use_color safe_term match_lhs

# Commented out, don't overwrite xterm -T "title" -n "icontitle" by default.
# If this is an xterm set the title to user@host:dir
#case "$TERM" in
#xterm*|rxvt*)
#    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
#    ;;
#*)
#    ;;
#esac

# enable bash completion in interactive shells
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# sudo hint
#if [ ! -e $HOME/.sudo_as_admin_successful ]; then
#    case " $(groups) " in *\ admin\ *)
#    if [ -x /usr/bin/sudo ]; then
#	cat <<-EOF
#	To run a command as administrator (user "root"), use "sudo <command>".
#	See "man sudo_root" for details.
#	
#	EOF
#    fi
#    esac
#fi

# if the command-not-found package is installed, use it
if [ -x /usr/lib/command-not-found ]; then
	function command_not_found_handle {
	        # check because c-n-f could've been removed in the meantime
                if [ -x /usr/lib/command-not-found ]; then
		   /usr/bin/python /usr/lib/command-not-found -- $1
                   return $?
		else
		   return 127
		fi
	}
fi

#Eigenen Eintraege


alias '..'='cd ..'
