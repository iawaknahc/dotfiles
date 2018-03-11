export VISUAL='vim'
export EDITOR="$VISUAL"
export PS1='$ '
export PS2='> '
export LC_ALL='en_US.UTF-8'
set -o vi

replace() {
  searcher=''
  if [ -x "$(command -v rg)" ]; then
    searcher='rg'
  elif [ -x "$(command -v ag)" ]; then
    searcher='ag'
  else
    1>&2 echo 'neither rg nor ag is in PATH'
    return 1
  fi
  pattern=$(printf '%s' "$1" | perl -pe 's/\//\\\//g')
  replacement=$(printf '%s' "$2" | perl -pe 's/\//\\\//g')
  "$searcher" -0ls "$1" | xargs -0 perl -pi -e "s/$pattern/$replacement/g"
}

backup_macos() {
  COPYFILE_DISABLE=true tar czf "$1" -C "$HOME" Library/Keychains .ssh .gnupg
}

dotfiles() {
  git_dir="$HOME/.dotfiles.git"
  work_tree="$HOME"
  gitignore="$git_dir/info/exclude"

  case "$1" in
  'cat-ignore')
    cat "$gitignore"
    ;;
  'write-ignore')
    cat - > "$gitignore"
    ;;
  *)
    GIT_DIR="$git_dir" GIT_WORK_TREE="$work_tree" git "$@"
    ;;
  esac
}


# android
if [ -d "/usr/local/share/android-sdk" ]; then
  ANDROID_SDK_ROOT="/usr/local/share/android-sdk"
  export ANDROID_SDK_ROOT
fi

# fzf
if [ -x "$(command -v fd)" ]; then
  export FZF_DEFAULT_COMMAND='fd --type file --hidden'
elif [ -x "$(command -v rg)" ]; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden'
elif [ -x "$(command -v ag)" ]; then
  export FZF_DEFAULT_COMMAND='ag -g "" --hidden'
fi

# asdf
if [ -d "$HOME/.asdf" ]; then
  . "$HOME/.asdf/asdf.sh"
  . "$HOME/.asdf/completions/asdf.bash"
fi

# golang
if [ -d "$HOME/go" ]; then
  export GOPATH="$HOME/go"
  if [ -d "$HOME/go/bin" ]; then
    export PATH="$HOME/go/bin:$PATH"
  fi
fi

# rust
if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# opam
if [ -x "$(command -v opam)" ]; then
  # Workaround the following issue by
  # running the command twice
  # https://github.com/ocaml/opam/issues/2159
  eval "$(opam config env)"
  eval "$(opam config env)"
fi

# brew specific
if [ -x "$(command -v brew)" ]; then
  # bash specific
  if [ "$(basename "$SHELL")" = 'bash' ]; then
    # enable bash completion
    [ -f "$(brew --prefix)/etc/bash_completion" ] && . "$(brew --prefix)/etc/bash_completion"
  fi
fi

# watchman
export WATCHMAN_CONFIG_FILE="$HOME/.watchman.json"
