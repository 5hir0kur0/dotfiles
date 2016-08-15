#!/usr/bin/env bash

DIR="$(pwd)"

[ -f "$HOME/.vimrc" ]             || ln -s "$DIR/.vimrc" "$HOME/.vimrc"
[ -d "$HOME/.vim" ]               || mkdir "$HOME/.vim"
[ -d "$HOME/.vim/backup" ]        || mkdir "$HOME/.vim/backup"
[ -d "$HOME/.vim/swp" ]           || mkdir "$HOME/.vim/swp"

[ -f "$HOME/.bashrc" ]            || ln -s "$DIR/.bashrc" "$HOME/.bashrc" 
[ -f "$HOME/.zshrc" ]             || ln -s "$DIR/.zshrc" "$HOME/.zshrc"
[ -f "$HOME/.tmux.conf" ]         || ln -s "$DIR/.tmux.conf" "$HOME/.tmux.conf"
[ -d "$HOME/.i3" ]                || ln -s "$DIR/.i3" "$HOME"
[ -f "$HOME/.vimperatorrc" ]      || ln -s "$DIR/vimperator/.vimperatorrc" "$HOME"
[ -d "$HOME/.config" ]            || mkdir "$HOME/.config"
[ -d "$HOME/.config/dunst" ]      || ln -s "$DIR/dunst" "$HOME/.config/dunst"
[ -d "$HOME/.vimperator" ]        || mkdir "$HOME/.vimperator"
[ -d "$HOME/.vimperator/colors" ] || mkdir "$HOME/.vimperator/colors"


if [ ! -f "$HOME/.vimperator/colors/darkness.vimp" ]; then
  cp "$DIR/vimperator/darkness.vimp" "$HOME/.vimperator/colors/"
fi


if [ ! -f "$HOME/.config/redshift.conf" ]; then
  cp "$DIR/redshift.conf" "$HOME/.config/redshift.conf"
  echo -n "latitude:  " && read LAT
  echo -n "longitude: " && read LON
  echo "lat=$LAT" >> "$HOME/.config/redshift.conf"
  echo "lon=$LON" >> "$HOME/.config/redshift.conf"
fi

GIT='false'
which git &> /dev/null && GIT='true'
if $GIT; then
  git config --global --list &> /dev/null
  [ "$?" -eq 0 ] && GIT='false'
fi

if $GIT; then
  echo 'configuring git...'
  echo -n 'username: ' && read USERNAME
  git config --global user.name "$USERNAME"
  echo -n 'email: ' && read EMAIL
  git config --global user.email "$EMAIL"
  git config --global core.editor vim
  git config --global push.default simple
  git config --global merge.tool vimdiff
  git config --global alias.pull 'git pull --ff --only-ff'
else
  echo 'git is not installed or already configured'
fi
