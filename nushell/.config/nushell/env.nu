# env.nu
#
# Installed by:
# version = "0.108.0"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.

## PATH

use std/util 'path add'

path add '~/.local/bin'

# rust
path add ($env.CARGO_HOME? | default ('~/.cargo' | path expand) | path join 'bin')

path add ('~/.local/bin' | path expand )

# golang
path add ($env.GOPATH | path join 'bin')

# doom emacs
path add ('~/.config/emacs/bin' | path expand)

# lean
path add ('~/.elan/bin' | path expand)

## ENV

if $env.TERM_PROGRAM == vscode {
    $env.EDITOR = 'code --wait'
} else {
    $env.EDITOR = 'nvim'
}
$env.VISUAL = $env.EDITOR


$env.LESS = '--mouse --use-color --ignore-case --chop-long-lines --raw-control-chars --incsearch --LONG-PROMPT'

# build makepkg packages in /tmp (yields better performance because then
# they're built in RAM [I mount /tmp as tmpfs])
$env.BUILDDIR = "/tmp/.build-" + $env.USER

# display man pages using neovim
$env.MANPAGER = "nvim '+Man!'"

# Check if the given program is installed
def is-installed [] {
  each { |name| which $name | is-not-empty }
}

if ("zoxide" | is-installed) {
  zoxide init nushell | save -f ~/.config/nushell/.zoxide.nu
} else {
  touch ~/.config/nushell/.zoxide.nu
}
