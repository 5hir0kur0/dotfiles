# config.nu
#
# Installed by:
# version = "0.108.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R


$env.config.buffer_editor = "helix"
$env.config.show_banner = false
$env.config.rm.always_trash = true
$env.config.completions.algorithm = "prefix"
$env.config.use_kitty_protocol = true
$env.config.table.mode = "compact" # "frameless"
$env.config.table.index_mode = "auto"

## KEYBINDINGS

$env.config.keybindings ++= [
  {
    name: insert_last_token
    modifier: alt
    keycode: char_.
    mode: [emacs vi_normal vi_insert]
    event: [
      { edit: InsertString, value: "!$" }
      { send: Enter }
    ]
  }
]

## PROMPT
#
# Ported from the fish/zsh prompt:
#   left  : [exit code] (only on failure) + home-relative, width-shortened path
#   right : ~user + command duration (only if slow) + git branch (magenta = dirty)

# format a number of seconds as a human-readable duration (mirrors fish __my_displaytime)
def _my_displaytime [t: int]: nothing -> string {
    let d = $t // 60 // 60 // 24
    let h = $t // 60 // 60 mod 24
    let m = $t // 60 mod 60
    let s = $t mod 60
    mut out = ""
    if $d > 0 { $out = $"($out)($d)d " }
    if $h > 0 { $out = $"($out)($h)h " }
    if $m > 0 { $out = $"($out)($m)m " }
    $"($out)($s)s"
}

# target width for the shortened pwd, ~32% of terminal width (mirrors fish __my_prompt_width)
def _my_prompt_width []: nothing -> int {
    (term size).columns * 32 / 100 | math floor | into int
}

# shorten path elements (except first/last) to fit a target width (mirrors fish __my_fit_path)
def _my_fit_path [path: string, desired_length: int]: nothing -> string {
    mut elements = ($path | split row '/')
    let n = ($elements | length)
    if $n <= 2 { return $path }
    for i in 1..($n - 2) {
        let current = ($elements | str join '/')
        if ($current | str length) <= $desired_length { return $current }
        $elements = ($elements | update $i {|e| $e | str substring 0..<1 })
    }
    $elements | str join '/'
}

# home-relative pwd, shortened to fit the terminal width (mirrors fish __my_pwd_display)
def _my_pwd_display []: nothing -> string {
    let pwd_display = if $env.PWD == $env.HOME {
        "~"
    } else if ($env.PWD | str starts-with $"($env.HOME)/") {
        $env.PWD | str replace $env.HOME "~"
    } else {
        $env.PWD
    }
    let width = (_my_prompt_width)
    let target = ([1 ($width - 2)] | math max)
    if ($pwd_display | str length) <= $width {
        _my_fit_path $pwd_display $target
    } else {
        let fitted = (_my_fit_path $pwd_display $target)
        if ($fitted | str length) > $width {
            # emulate zsh's "%<…<" truncation from the left if still too long
            let pos = ([0 (($fitted | str length) - $width + 1)] | math max)
            $"…($fitted | str substring $pos..)"
        } else {
            $fitted
        }
    }
}

# whether the current directory is writable (drives the red-path warning)
def _my_pwd_writable []: nothing -> bool {
    (^test -w $env.PWD | complete).exit_code == 0
}

# compact git branch/dirty status (mirrors fish __my_git_status)
def _my_git_status []: nothing -> string {
    let head = (^git symbolic-ref --short HEAD | complete)
    mut branch = (if $head.exit_code == 0 { $head.stdout | str trim } else { "" })
    if ($branch | is-empty) {
        let short = (^git rev-parse --short HEAD | complete)
        $branch = (if $short.exit_code == 0 { $short.stdout | str trim } else { "" })
    }
    if ($branch | is-empty) { return "" }

    let clean = (^git diff --no-ext-diff --quiet | complete)
    let unstaged = (if $clean.exit_code != 0 { ansi magenta_bold } else { "" })

    $" (ansi blue)[(ansi cyan)($unstaged)($branch)(ansi reset)(ansi blue)](ansi reset)"
}

$env.PROMPT_COMMAND = {||
    let exit_display = if $env.LAST_EXIT_CODE != 0 {
        $"(ansi red_bold)[($env.LAST_EXIT_CODE)] (ansi reset)"
    } else { "" }
    let path_color = if (_my_pwd_writable) { ansi cyan } else { ansi red }
    $"($exit_display)($path_color)(_my_pwd_display)(ansi reset)"
}

$env.PROMPT_COMMAND_RIGHT = {||
    let user_display = $"(ansi reset)(ansi attr_dimmed)~($env.USER)(ansi reset)"
    let dur = ($env.CMD_DURATION_MS? | default "0" | into int)
    let runtime_display = if $dur > 10000 {
        $" (ansi cyan)[(_my_displaytime ($dur // 1000))](ansi reset)"
    } else { "" }
    let git_display = (_my_git_status)
    $"($user_display)($runtime_display)($git_display)"
}

# the "%"/"#" typed after the path (green, "#" when root); replaces the default " > "
$env.PROMPT_INDICATOR = {||
    let ch = if (is-admin) { '#' } else { '%' }
    $" (ansi fuchsia)($ch)(ansi reset) "
}

## COMPLETIONS

let fish_completer = {|spans|
  fish --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
  | from tsv --flexible --noheaders --no-infer
  | rename value description
  | update value {|row|
    let value = $row.value
    let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
    if ($need_quote and ($value | path exists)) {
      let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
      $'"($expanded_path | str replace --all "\"" "\\\"")"'
    } else {$value}
  }
}
$env.config.completions.external = {
  enable: true
  completer: $fish_completer
}

## FUNCTIONS
#
# Ports of the zsh/fish shell functions. Nushell resolves `def`s in a second
# parse pass, so a function may reference another defined further down; the
# order here is otherwise alphabetical.

# run `find`, returning its stdout but swallowing stderr and exit status (like the zsh `2>/dev/null`)
def --wrapped _findq [...args] {
    do --ignore-errors { ^find ...$args e> /dev/null } | complete | get stdout
}

# find broken symlinks under the given paths (default: .)
def brokenlinks [...paths: string] {
    let p = if ($paths | is-empty) { ["."] } else { $paths }
    _findq ...$p -type l | lines | where {|l| not ($l | path exists) }
}

# histogram of file mime types under the given paths (default: .)
def counttypes [...paths: string] {
    let p = if ($paths | is-empty) { ["."] } else { $paths }
    _findq ...$p -type f | lines | chunks 500 | each {|b| ^file --brief --mime ...$b | lines } | flatten | uniq -c | sort-by count
}

# exec a shell inside a running docker container
def deitsh [container: string] {
    ^docker exec -it $container /bin/sh
}

# open files in emacsclient, detached from the shell
def --wrapped e [...args] {
    ^setsid --fork -- emacsclient ...$args
}

# case-insensitive name search in the current directory only
def f [pattern: string] {
    _findq . -maxdepth 1 -iname $"*($pattern)*"
}

# giant live-updating unix timestamp; `fmt` is a printf conversion (default X = hex). ^C to quit
def fancy_unixtime [fmt: string = "X"] {
    mut oldf = ""
    loop {
        let secs = (^date +%s)
        let newf = (^figlet -W -f banner -tc (^printf $"%($fmt)\n" $secs))
        if $oldf != $newf {
            print -n "\u{1b}[2J\u{1b}[0;0H"  # clear screen, cursor home
            print $newf
            $oldf = $newf
        }
        sleep 100ms
    }
}

# case-insensitive recursive name search
def ff [pattern: string] {
    _findq . -iname $"*($pattern)*"
}

# find hard links to a file
def findhardlinks [start_dir: string, file: string] {
    _findq $start_dir -samefile $file
}

# find any link (hard or soft, following symlinks while searching) to a file
def findlinks [start_dir: string, file: string] {
    _findq -L $start_dir -samefile $file
}

# find files not accessed in `days` days (default 60) under `dir` (default .)
def findoldfiles [dir: string = ".", days: int = 60] {
    _findq $dir -atime $"+($days)"
}

# find soft links to a file
def findsoftlinks [start_dir: string, file: string] {
    _findq -L $start_dir -xtype l -samefile $file
}

# recursive perl-regex grep inside PDFs
def gpdf [pattern: string, dir: string = "."] {
    do --ignore-errors { ^pdfgrep -iP $pattern -R $dir } | complete | get stdout
}

# cd into the directory a symlink actually points to
def --env lcd [link: string] {
    let target = (^readlink -f $link | str trim)
    match ($target | path type) {
        "file" => { cd ($target | path dirname) }
        "dir" => { cd $target }
        _ => {}
    }
}

# follow a pipe with less, resumable with F after ^C
def less_pipe [pipe_command: string] {
    let tempfile = (^mktemp /tmp/.less_pipe.XXXX)
    let pgidfile = (^mktemp /tmp/.less_pipe.pgid.XXXX)
    # run the producer in its own session so the whole pipeline can be killed
    ^setsid --fork sh -c $"echo $$ > ($pgidfile); exec ($pipe_command) > ($tempfile)"
    ^less --RAW-CONTROL-CHARS --chop-long-lines -n +F -- $tempfile
    let pgid = (open $pgidfile | str trim)
    if ($pgid | is-not-empty) { do --ignore-errors { ^kill -- $"-($pgid)" } }
    ^rm -v -- $tempfile $pgidfile
}

# build a PDF with latexmk (lualatex) and clean up
def llpdf [...files: string] {
    if ($files | is-empty) { error make {msg: "llpdf: missing file name"} }
    do --ignore-errors { ^latexmk -lualatex ...$files }
    ^latexmk -c
}

# view log file(s) through ccze + colorized less
def log_view [...files: string] {
    if ($files | is-empty) { error make {msg: "log_view: expected file name(s)"} }
    ^cat ...$files | ^ccze --raw-ansi | ^less -rFXS
}

# build a PDF with latexmk (pdflatex) and clean up
def lpdf [...files: string] {
    if ($files | is-empty) { error make {msg: "lpdf: missing file name"} }
    do --ignore-errors { ^latexmk -pdf ...$files }
    ^latexmk -c
}

# launch quietly (stdout hidden) and detach from the shell
def --wrapped lqd [...cmd] {
    if ($cmd | is-empty) { error make {msg: "lqd: expected a command"} }
    ^setsid --fork -- ...$cmd out> /dev/null
}

# launch quietly (stdout+stderr hidden) and detach from the shell
def --wrapped lqqd [...cmd] {
    if ($cmd | is-empty) { error make {msg: "lqqd: expected a command"} }
    ^setsid --fork -- ...$cmd out+err> /dev/null
}

# `ls` variants that need a pipeline (aliases can't contain `|`)
def lr [] { ls --all --long | sort-by modified --reverse }
def lrr [] { lr | first 10 }

# mkdir -p the given directory and cd into it
def --env mcd [dir: string] {
    if not ($dir | path exists) { mkdir $dir }
    cd $dir
}

# summed memory (RSS) of every process whose name matches
def memusage [name: string] {
    ps | where name =~ $name | get mem | math sum
}

# collect a pid and all its descendants from a `ps -l` snapshot
def _proc_tree [procs: table, roots: list<int>] {
    mut all = $roots
    mut frontier = $roots
    while ($frontier | is-not-empty) {
        let kids = ($procs | where ppid in $frontier | get pid)
        $all = ($all | append $kids)
        $frontier = $kids
    }
    $all | uniq
}

# summed memory (RSS) of a process and all its descendants
def memusage_pid [pid: int] {
    let procs = (ps -l)
    $procs | where pid in (_proc_tree $procs [$pid]) | get mem | math sum
}

# summed memory (RSS) of every process matching `name`, plus all their descendants
def memusage_total [name: string] {
    let procs = (ps -l)
    let roots = ($procs | where name =~ $name | get pid)
    $procs | where pid in (_proc_tree $procs $roots) | get mem | math sum
}

# run a command and notify-send when it finishes (used by the alert_completion aliases)
def --wrapped _my_alert_completion [...args] {
    if ($args | is-empty) { error make {msg: "_my_alert_completion: expected a command"} }
    mut rest = $args
    mut notify_arg = "--all"
    if ($rest | first) == "--only-me" {
        $rest = ($rest | skip 1)
        $notify_arg = (^id --user | str trim)
    }
    let start = (date now)
    let how = try { ^($rest | first) ...($rest | skip 1); "completed" } catch { "failed" }
    print -n (char bel)  # bell for tmux
    let secs = (((date now) - $start) / 1sec | into int)
    _my_notify_send $notify_arg $"Task ($how) in (_my_displaytime $secs)" ($rest | str join " ")
}

# make notify-send work across users/sessions; `target` is --all or a uid
def _my_notify_send [target: string, ...args: string] {
    let bus_paths = if $target == "--all" {
        glob /run/user/*/bus
    } else {
        [$"/run/user/($target)/bus"]
    }
    for bus in $bus_paths {
        let uid = ($bus | parse "/run/user/{uid}/bus" | get 0.uid)
        ^sudo -u $"#($uid)" env $"DBUS_SESSION_BUS_ADDRESS=unix:path=($bus)" notify-send ...$args
    }
}

# wrap man in nvim so code samples keep syntax highlighting
def _nvim_man [...args: string] {
    ^nvim $"+Man ($args | str join ' ') | bd #"
}

# tail the stdout+stderr fds of a process matched by name
def output [name: string] {
    let pids = (do --ignore-errors { ^pgrep $name } | lines)
    if ($pids | is-empty) { error make {msg: "output: process not found"} }
    let pid = ($pids | first)
    ^tail -f $"/proc/($pid)/fd/1" $"/proc/($pid)/fd/2"
}

# quietly open files with xdg-open (stdout hidden), detached
def qo [...files: string] {
    for file in $files { lqd xdg-open $file }
}

# quietly open files with xdg-open (stdout+stderr hidden), detached
def qqo [...files: string] {
    for file in $files { lqqd xdg-open $file }
}

# strace with a fuller flag set, logging to a file
def strace-fancy [logfile: string, binary: string] {
    ^strace -ftrCDTYyy -o $logfile -v -s128 $binary
}

# system health summary (zsh calls this `status`, a reserved word in fish/nu-adjacent shells)
def sys_status [disk: string = "/dev/sda"] {
    # every tool here reports trouble via a non-zero exit, so ignore exit status
    print "    failed system services:"
    do --ignore-errors { ^systemctl --failed }
    print "    high priority log errors:"
    do --ignore-errors { ^journalctl -p3 -xb }
    print $"    smart status of ($disk):"
    do --ignore-errors { ^sudo smartctl --health $disk }
    if (which pacman | is-not-empty) {
        print "    modified or missing files of installed packages:"
        do --ignore-errors { ^pacman -Qkk } | ignore
    }
}

# full system upgrade + interactive pacdiff (zsh `update`; nu reserves that name for a builtin)
def sysupdate [] {
    ^paru -Syu
    ^sudo DIFFPROG='nvim -d' pacdiff
}

# tail -f log file(s) through ccze
def tail_ccze [...files: string] {
    if ($files | is-empty) { error make {msg: "tail_ccze: expected file name(s)"} }
    ^tail --retry --follow=name ...$files | ^ccze --raw-ansi
}

# cd up `n` directories (default 1)
def --env up [n: int = 1] {
    cd (1..$n | each { ".." } | path join)
}

# current weather for `location` (default: first line of ~/.local/share/.location)
def weather [location?: string] {
    let loc = if $location != null { $location } else { open ~/.local/share/.location | lines | first }
    ^curl --insecure --silent $"https://wttr.in/($loc)?q"
}

# build a PDF with latexmk (xelatex) and clean up
def xlpdf [...files: string] {
    if ($files | is-empty) { error make {msg: "xlpdf: missing file name"} }
    do --ignore-errors { ^latexmk -xelatex ...$files }
    ^latexmk -c
}

# yazi wrapper that changes to the directory selected on exit
def --env yazi_cd [...args] {
    let tmp = (mktemp -t ".yazi-cwd.XXXXXX")
    ^yazi ...$args --cwd-file $tmp
    let cwd = (open $tmp)
    if $cwd != $env.PWD and ($cwd | path exists) {
        cd $cwd
    }
    \rm -fp $tmp
}

## ALIASES

source ~/.config/nushell/.zoxide.nu

alias alert_completion_me = _my_alert_completion --only-me
alias chardiff = git diff --no-index --word-diff=color --word-diff-regex=.
alias \cp = cp
alias cp = cp --progress --interactive
alias diff = diff --color=auto
alias displaytime = _my_displaytime
alias dmesg = dmesg --follow --time-format reltime
alias drmit = docker run --interactive --tty --rm
alias dsai = docker start -ai
alias enw =  emacs -nw
alias fd-all = fd --follow --full-path --hidden --no-ignore --show-errors
alias fg = job unfreeze
alias gcc = gcc -Wall -Wextra -std=c23
alias gg = git grep -i --break --heading
alias g = git
alias g++ = g++ -Wall -Wextra -std=c++23
alias gitroot = cd (git rev-parse --show-toplevel)
alias grep = grep -i --color=auto
alias gr = gitroot
alias hx = helix
alias ip = ip -color
alias ji = zi
alias j = z
alias la = ls --all
alias lessjournal = less_pipe 'journalctl --boot 0 --follow --no-tail | ccze --raw-ansi'
alias lessmesg = less_pipe 'dmesg --follow --time-format reltime --color=always --nopager'
alias lla = ls --all --long
alias ll = ls
alias l = ^ls -q --color=auto --hyperlink=auto
alias lsd = ls --long --directory
alias man = _nvim_man
alias md = mkdir
alias mpva = mpv --no-video
alias \mv = mv
alias mv = mv --interactive --verbose
alias npr = npm run
alias rg-all = rg --smart-case --hidden
alias rg = rg --smart-case
alias \rm = rm
alias rm = rm --trash --interactive
alias r = yazi_cd
alias strace = strace -fCDYyy
alias vgit = nvim -c 'autocmd User NeogitStatusRefreshed nnoremap <buffer> <nowait> q <cmd>q<cr>' -c 'Neogit kind=replace'
alias view = nvim -R -n +'set nomodifiable noswapfile noundofile shadafile= viewoptions=cursor' +'nnoremap q ZQ'
alias vimdiff = nvim -d
alias vim = nvim
alias v = nvim
alias wttr = weather
alias yazi = yazi_cd
alias yta = yt-dlp --add-metadata -xic
alias yt = yt-dlp --add-metadata -ic
alias y = yazi_cd
