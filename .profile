# https://superuser.com/questions/544989/does-tmux-sort-the-path-variable
if [ -f "/etc/profile" ]; then
  PATH=""
  . "/etc/profile"
fi

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
if [ -d "${HOME}/Library/Android/sdk" ]; then
  export ANDROID_SDK_ROOT="${HOME}/Library/Android/sdk"
  export ANDROID_HOME="$ANDROID_SDK_ROOT"
  if [ -d "${ANDROID_SDK_ROOT}/platform-tools" ]; then
    export PATH="${ANDROID_SDK_ROOT}/platform-tools:$PATH"
  fi
  if [ -d "${ANDROID_SDK_ROOT}/tools/bin" ]; then
    export PATH="${ANDROID_SDK_ROOT}/tools/bin:$PATH"
  fi
fi

# fzf
if [ -x "$(command -v fd)" ]; then
  export FZF_DEFAULT_COMMAND='fd --type file --hidden'
elif [ -x "$(command -v rg)" ]; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden'
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

# flutter
if [ -d "$HOME/flutter/bin" ]; then
  export PATH="$HOME/flutter/bin:$PATH"
fi

# opam
if [ -x "$(command -v opam)" ]; then
  eval "$(opam env)"
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
