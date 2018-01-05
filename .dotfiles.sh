#!/bin/sh
set -eu

git_dir="$HOME/.dotfiles.git"
work_tree="$HOME"
gitignore="*
!.bash_profile
!.bashrc
!.dotfiles.sh
!.profile
!.tmux.conf
!.vimrc
!.watchman.json"

error() {
  >&2 echo "$@"
  exit 1
}

dotfiles() {
  GIT_DIR="$git_dir" GIT_WORK_TREE="$work_tree" git "$@"
}

if [ "$#" -ne 1 ]; then
  error 'expected your dotfiles repository url'
fi

if [ -e "$git_dir" ]; then
  error "$git_dir exists"
fi

dotfiles init \
  && dotfiles remote add origin "$1" \
  && dotfiles fetch origin \
  && dotfiles checkout -b m origin/master \
  && echo "$gitignore" > "$git_dir/info/exclude"
# I could not figure out why the following line
# must be executed on its own. Otherwise
# git will complain branch `master` not found.
dotfiles branch -m master
