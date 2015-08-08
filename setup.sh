#!/usr/bin/env bash

DIR="$(pwd)"

ln -s "$DIR/.vimrc" "$HOME/.vimrc"
ln -s "$DIR/.bashrc" "$HOME/.bashrc" 
ln -s "$DIR/.zshrc" "$HOME/.zshrc"
ln -s "$DIR/.i3" "$HOME/.i3"

GIT=false
which git > /dev/null && GIT=true

if $GIT; then
  echo 'configuring git...'
  echo -n 'username: ' && read USERNAME
  git config --global user.name "$USERNAME"
  echo -n 'email: ' && read EMAIL
  git config --global user.email "$EMAIL"
  git config --global core.editor vim
  git config --global push.default simple
  git config --global merge.tool vimdiff
else
  echo 'git is not installed'
fi
