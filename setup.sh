#!/usr/bin/env bash

set -euo pipefail

STOW_DIRECTORY=$( cd "$(dirname "$0")"; pwd -P )
STOW_TARGET=$HOME

function install_pkg() {
    echo 'stow is missing; trying to install it...' 1>&2
    if hash apt; then
        sudo apt install "${1:?pkg name missing}"
    elif hash pacman; then
        sudo pacman -Sy "${1:?pkg name missing}"
    fi
}

function my_stow() {
    if ! hash stow; then
        install_pkg stow
    fi
    stow --target="$STOW_TARGET" --dir="$STOW_DIRECTORY" --verbose \
            --no-folding "$@"
}

if [ -z "${1:-}" ]; then
    echo "usage: $0 [--stow|--delete|--restow] <dirname>" 1>&2
    echo "  (use --no to simulate)" 1>&2
    exit 1
fi

if [ "${1:-}" = git ]; then
    GIT=1
    if ! hash git; then
        install_pkg git
    fi
    if git config --global --list &> /dev/null; then
        GIT=0
    fi

    if [ "$GIT" -eq 1 ]; then
        echo 'configuring git...'
        echo -n 'username: ' && read USERNAME
        git config --global user.name "$USERNAME"
        echo -n 'email: ' && read EMAIL
        git config --global user.email "$EMAIL"
        git config --global core.editor nvim
        git config --global push.default simple
        git config --global merge.tool vimdiff
        git config --global alias.pull 'git pull --ff --only-ff'
    else
        echo 'git is already configured' 1>&2
    fi
else
    my_stow "$@"
fi
