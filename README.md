# My Personal Dotfiles

This repository contains my personal configuration files for using (Arch) Linux.
Most of it is severely under-documented.

## Usage

I have a setup script, which is a wrapper around [GNU
stow](https://www.gnu.org/software/stow/), to install (symlink) my
configuration. For example, run the following to set up my `i3` configuration:

``` sh
./setup.sh --stow i3
```

Note that this does *not* work for all of the directories in this repository as
some of them are for global configuration files, e.g. in `/etc`.

To install all (official repo) packages in the package list, run:

``` sh
yes | ./pkginstall_arch.sh pkglist_arch
```

This only works on Arch Linux.

## Screenshot

![Fake busy screenshot](https://raw.githubusercontent.com/5hir0kur0/dotfiles/screenshots/rice.png)

Fake busy. Programs in screenshot:
- [i3 (window manager)](https://i3wm.org/)
- [tmux](https://github.com/tmux/tmux)
- [bpytop (system monitor)](https://github.com/aristocratos/bpytop)
- [neofetch](https://github.com/dylanaraps/neofetch)
- [zsh (shell)](https://www.zsh.org/)
- [doom](https://github.com/hlissner/doom-emacs) [emacs](https://www.gnu.org/software/emacs/)
