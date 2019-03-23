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
        cp ./git/.gitconfig ~
        echo 'configuring git...'
        echo -n 'username (leave blank for default): ' && read -r USERNAME
        [ -n "$USERNAME" ] && git config --global user.name "$USERNAME"
        [ -n "$USERNAME" ] && git config --global credential.username "$USERNAME"
        echo -n 'email: ' && read -r EMAIL
        git config --global user.email "$EMAIL"
    else
        echo 'git is already configured' 1>&2
    fi
else
    my_stow "$@"
fi
