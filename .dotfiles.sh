#!/bin/sh
set -eu

git_dir="$HOME/.dotfiles.git"
work_tree="$HOME"

error() {
  >&2 echo "$@"
  exit 1
}

g() {
  GIT_DIR="$git_dir" GIT_WORK_TREE="$work_tree" git "$@"
}

if [ "$#" -ne 1 ]; then
  error 'expected your dotfiles repository url'
fi

if [ -e "$git_dir" ]; then
  error "$git_dir exists"
fi

g init
g remote add origin "$1"
g fetch origin
g checkout -b m origin/master
g branch -D master || true
g branch -m master
