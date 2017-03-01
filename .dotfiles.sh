#!/bin/sh

git_dir="$HOME/.dotfiles.git"
work_tree="$HOME"

log_error() {
  >&2 echo "$@"
}

dotfiles() {
  git --git-dir="$git_dir" --work-tree="$work_tree" "$@"
}

if [ "$#" -ne 1 ]; then
  log_error "expected your dotfiles repository url"
  exit 1
fi

if [ -e "$git_dir" ]; then
  log_error "$git_dir exists"
  exit 1
fi

dotfiles init
dotfiles remote add origin "$1"
dotfiles fetch origin
output=$(2>&1 dotfiles checkout -b master origin/master)
if [ "$?" -ne 0 ]; then
  output=$(echo "$output" | grep -e '^\t' | perl -p -e 's/^\t//')
  temp_dir=$(cat /dev/urandom | env LC_CTYPE=C tr -cd 'a-f0-9' | head -c 32)
  temp_dir="$work_tree/$temp_dir"
  echo "making temp dir: $temp_dir"
  mkdir "$temp_dir"
  echo "$output" |
  while IFS= read -r line; do
    oldpath="$work_tree/$line"
    newpath="$temp_dir/$line"
    echo "moving $oldpath to $newpath"
    mv "$oldpath" "$newpath"
  done
  dotfiles checkout -b master origin/master
fi
