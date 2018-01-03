alias ls='ls -q --color=auto'
alias ll='ls -lh'
alias la='ls -A'
alias lla='la -Alh'
alias l='ls -C'
alias lr='ls -lAht'
alias lrr='lr | head'
alias lsd='ls -ld'
alias '..'='cd ..'
alias '...'='cd ../..'
alias '....'='cd ../../..'
alias '.....'='cd ../../../..'
alias mv='mv -iv'
alias rm='rm -Iv --one-file-system'
alias cp='cp --reflink=auto -iv'
alias vim=nvim
alias v=nvim

alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias -g g='grep'

alias less='less -FX'
alias -g c='less'

alias hcat="highlight --force -O ansi"

alias update='update.sh'

alias g++="g++ -Wall -Wextra -std=c++11"
alias gcc="gcc -Wall -Wextra -std=c99"

alias view="vim -R -c 'set nomodifiable'"

function f() {
    find . -maxdepth 1 -iname "*${1:?}*";
}

function ff() {
    find . -iname "*${1:?}*";
}

function fl() {
    find . -type f -exec grep -q "${1:?}" {} \; -print
}

function gf() {
    grep "${1:?}" -R .
}

# launch quietly and disown
function lqd() {
    ( ${@:?} ) > /dev/null & disown
}

function lqqd() {
    ( $@ ) >& /dev/null & disown
}

function qo() {
    for FILE in $@; do
        lqd xdg-open $FILE
    done
}

function qqo() {
    for FILE in $@; do
        lqqd xdg-open $FILE
    done
}

# TODO: make this work with multiple pids
function output() {
    PID=`pgrep "${1:?}"`
    tail -f "/proc/${PID:?not found}/fd/1" "/proc/$PID/fd/2"
}

# stolen from https://stackoverflow.com/a/3854444
function memusage() {
    if [ -z "${1:-}" ]; then
        echo "usage: memusage <process_name> [<type>]" 1>&2
        cat 1>&2 << EOF
    values for <type>:
        Rss: resident memory usage, all memory the process uses,
             including all memory this process shares with other processes.
             It does not include swap;
        Shared: memory that this process shares with other processes;
        Private: private memory used by this process, 
             you can look for memory leaks here;
        Swap: swap memory used by the process;
        Pss: Proportional Set Size, a good overall memory indicator.
             It is the Rss adjusted for sharing: 
             if a process has 1MiB private and 20MiB shared between other 10
             processes, Pss is 1 + 20/10 = 3MiB
EOF
        return 1
    fi
    PIDS=( $(pgrep -x $1) )
    for PID in "${PIDS[@]}"; do
        echo 0 $(awk "/${2:-Pss}/ {print \"+\", \$2}" "/proc/$PID/smaps") | bc
    done
}

function memusage_total() {
    memusage "$@" | paste -sd+ | bc
}

function fancy_unixtime() {
    OLDF=""
     while true; do
         SECS=`date +%s`
         BASE="${1-16}"
         NEWF="$(figlet -W -f banner -tc $(echo "obase=$BASE; $SECS" | bc))"
         if [ ! "$OLDF" = "$NEWF" ]; then
             echo -n "\x1B[2J\x1B[0;0H"; #clear screen and move cursor to 0,0
             echo "$NEWF"
             OLDF="$NEWF"
         fi
         sleep 0.1
    done
}

function status() {
    echo '    failed system services:'
    systemctl --failed
    echo '    high priority log erros:'
    journalctl -p3 -xb
    echo '    smart status of /dev/sda or $1:'
    sudo smartctl --health "${1:-/dev/sda}"
    if hash pacman; then
        echo '    modified or missing files of installed packages:'
        pacman -Qkk 1>/dev/null
    fi
}

# go up n directories
# stolen from: https://www.reddit.com/r/ProgrammerHumor/comments/4f2o6l/typical_entrepreneurs/d25o3wu
function up() {
    cd $(eval printf '../'%.0s {1.."${1:?}"})
}

function weather() {
    LOC=${1:-$(head -1 ~/.local/share/.location)}
    curl --insecure --silent "https://wttr.in/$LOC?q" #\
	# | grep -E '^\s*┌|│|└' --color=never
}

alias wttr=weather

function counttypes() {
    find ${*:-.} -type f -print0 | xargs -0 file --brief --mime | awk '
    {
        t[$0]++;
    }
    END {
        for (i in t) printf("%d\t%s\n", t[i], i);
    }' | sort -n
}

function brokenlinks() {
    find ${*:-.} -type l -print | perl -nle '-e || print'
}

function lpdf() {
    latexmk -pdf ${1:?missing file name}
    latexmk -c
}

function llpdf() {
    latexmk -lualatex ${1:?missing file name}
    latexmk -c
}
