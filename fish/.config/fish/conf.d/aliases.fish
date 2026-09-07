# Simple aliases (fish equivalent of `alias` lines in .zsh_aliases).
# Multi-line/complex logic lives in individual autoloaded files under
# ../functions/ instead.

alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
alias ...... 'cd ../../../../..'
alias ....... 'cd ../../../../../..'
alias ........ 'cd ../../../../../../..'
alias chardiff 'git diff --no-index --word-diff=color --word-diff-regex=.'
alias cp 'cp --reflink=auto -iv'
alias d dirs
alias diff 'diff --color=auto'
alias displaytime _my_displaytime
alias dmesg 'dmesg --follow --time-format reltime'
alias drmit 'docker run --interactive --tty --rm'
alias dsai 'docker start -ai'
alias encrypt_gpg 'gpg --symmetric'
alias enw 'emacs -nw'
alias fd-all 'fd --follow --full-path --hidden --no-ignore --show-errors'
alias gcc 'gcc -Wall -Wextra -std=c23'
alias gg 'git grep -i --break --heading'
alias g git
alias g++ 'g++ -Wall -Wextra -std=c++23'
alias gitroot 'cd (git rev-parse --show-toplevel)'
alias grep 'grep -i --color=auto'
alias gr gitroot
alias hx helix
alias ip 'ip -color'
alias la 'ls -A'
alias lessjournal "less_pipe 'journalctl --boot 0 --follow --no-tail | ccze --raw-ansi'"
alias lessmesg "less_pipe 'dmesg --follow --time-format reltime --color=always --nopager'"
alias lla 'ls -Alh'
alias ll 'ls -lh'
alias l 'ls -C'
alias lr 'ls -lAht'
alias lrr 'ls -lAht --color=always | head'
alias lsd 'ls -ld'
alias ls 'ls -q --color=auto --hyperlink=auto'
alias md mkdir
alias mkdir 'mkdir -pv'
alias mpva 'mpv --no-video'
alias mv 'mv -iv'
alias rg-all 'rg --smart-case --hidden'
alias rg 'rg --smart-case'
alias rm trash
alias r yazi_cd
alias strace 'strace -fCDYyy'
alias view "nvim -R -n +'set nomodifiable noswapfile noundofile shadafile= viewoptions=cursor' +'nnoremap q ZQ'"
alias vimdiff 'nvim -d'
alias vim nvim
alias v nvim
alias wttr weather
alias yazi yazi_cd
alias yta 'yt-dlp --add-metadata -xic'
alias yt 'yt-dlp --add-metadata -ic'
alias y yazi_cd

if test -f ~/.local_fish_aliases
    source ~/.local_fish_aliases
end
