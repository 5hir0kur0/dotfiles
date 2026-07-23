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

use std/util "path add"

path add "~/.local/bin"
path add ($env.CARGO_HOME | path join "bin")

$env.config.buffer_editor = "helix"
$env.config.show_banner = false

# Check if the given program is installed
def is-installed [] {
  each { |name| which $name | is-not-empty }
}

if ("zoxide" | is-installed) {
  zoxide init nushell | save -f ~/.config/nushell/.zoxide.nu
} else {
  touch ~/.config/nushell/.zoxide.nu
}
