#!/usr/bin/env bash

DIR="$(pwd)"

ln -s "$DIR/.vimrc" "$HOME/.vimrc"
ln -s "$DIR/.bashrc" "$HOME/.bashrc" 
ln -s "$DIR/.zshrc" "$HOME/.zshrc"
ln -s "$DIR/.i3" "$HOME"
test -d "$HOME/.config" || mkdir "$HOME/.config"
cp "$DIR/redshift.conf" "$HOME/.config/redshift.conf"
echo -n "latitude:  " && read LAT
echo -n "longitude: " && read LON
echo "lat=$LAT" >> "$HOME/.config/redshift.conf"
echo "lon=$LON" >> "$HOME/.config/redshift.conf"

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
