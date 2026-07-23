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

$env.PROMPT_INDICATOR = " % "

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
