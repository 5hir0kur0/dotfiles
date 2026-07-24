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
$env.config.table.mode = "frameless"
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

## ALIASES

source ~/.config/nushell/.zoxide.nu
alias j = z
alias ji = zi

alias fg = job unfreeze

alias vim = nvim
alias v = nvim
alias hx = helix
alias view = nvim -R -n +'set nomodifiable noswapfile noundofile shadafile= viewoptions=cursor' +'nnoremap q ZQ'
alias enw =  emacs -nw

alias ll = ls
alias md = mkdir
alias mv = mv --interactive --verbose
alias cp = cp --progress --interactive
alias rm = rm --trash --interactive

alias grep = grep -i --color=auto

alias diff = diff --color=auto
alias chardiff = git diff --no-index --word-diff=color --word-diff-regex=.
alias vimdiff = nvim -d

alias gitroot = cd (git rev-parse --show-toplevel)
alias gr = gitroot

alias g = git
alias gg = git grep -i --break --heading
alias rg = rg --smart-case
alias rg-all = rg --smart-case --hidden
alias fd-all = fd --follow --full-path --hidden --no-ignore --show-errors
alias ip = ip -color

alias lessmesg = less_pipe 'dmesg --follow --time-format reltime --color=always --nopager'
alias dmesg = dmesg --follow --time-format reltime
alias lessjournal = less_pipe 'journalctl --boot 0 --follow --no-tail | ccze --raw-ansi'

alias man = _nvim_man

alias g++ = g++ -Wall -Wextra -std=c++23
alias gcc = gcc -Wall -Wextra -std=c23

alias yt = yt-dlp --add-metadata -ic
alias yta = yt-dlp --add-metadata -xic

alias mpva = mpv --no-video

alias y = yazi_cd
alias yazi = yazi_cd
alias r = yazi_cd


alias alert_completion_me = _my_alert_completion --only-me

alias drmit = docker run --interactive --tty --rm
alias dsai = docker start -ai

alias strace = strace -fCDYyy

alias displaytime = _my_displaytime
