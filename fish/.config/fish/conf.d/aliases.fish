# Simple aliases (fish equivalent of `alias` lines in .zsh_aliases).
# Multi-line/complex logic lives in individual autoloaded files under
# ../functions/ instead.

alias gitroot 'cd (git rev-parse --show-toplevel)'
alias gr gitroot
alias vim nvim
alias v nvim
alias hx helix
alias vimdiff 'nvim -d'
alias view "nvim -R -n +'set nomodifiable noswapfile noundofile shadafile= viewoptions=cursor' +'nnoremap q ZQ'"

alias ew 'emacs -nw'

alias ls 'ls -q --color=auto --hyperlink=auto'
alias ll 'ls -lh'
alias la 'ls -A'
alias lla 'ls -Alh'
alias l 'ls -C'
alias lr 'ls -lAht'
alias lrr 'ls -lAht --color=always | head'
alias lsd 'ls -ld'
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
alias ...... 'cd ../../../../..'
alias ....... 'cd ../../../../../..'
alias ........ 'cd ../../../../../../..'

alias mv 'mv -iv'
alias mkdir 'mkdir -pv'
alias md mkdir
alias take mcd

alias rm trash
alias rmback 'trash *~'
alias cp 'cp --reflink=auto -iv'
alias d dirs

alias grep 'grep -i --color=auto'
alias diff 'diff --color=auto'
alias wdiff 'command dwdiff --color'
alias dwdiff wdiff
alias chardiff 'git diff --no-index --word-diff=color --word-diff-regex=.'
alias g git
alias gg 'git grep -i --break --heading'
alias rg 'rg --smart-case'
alias rg-all 'rg --smart-case --hidden'
alias fd-all 'fd --follow --full-path --hidden --no-ignore --show-errors'
alias ip 'ip -color'

alias encrypt_gpg 'gpg --symmetric'

alias c 'less -iFX'

alias lessmesg "less_pipe 'dmesg --follow --time-format reltime --color=always --nopager'"
alias dmesg 'dmesg --follow --time-format reltime'
alias lessjournal "less_pipe 'journalctl --boot 0 --follow --no-tail | ccze --raw-ansi'"

alias man _nvim_man

alias hcat 'highlight --force -O ansi'

alias g++ 'g++ -Wall -Wextra -std=c++23'
alias gcc 'gcc -Wall -Wextra -std=c23'

alias yt 'yt-dlp --add-metadata -ic'
alias yta 'yt-dlp --add-metadata -xic'

alias mpva 'mpv --no-video'

alias y yazi_cd
alias yazi yazi_cd
alias r yazi_cd

alias wttr weather

alias alert_completion _alert_completion
alias alert_completion_me '_alert_completion --only-me'

alias drmit 'docker run --interactive --tty --rm'
alias dsai 'docker start -ai'

alias strace 'strace -fCDYyy'

alias displaytime __my_displaytime

if test -f ~/.local_fish_aliases
    source ~/.local_fish_aliases
end
