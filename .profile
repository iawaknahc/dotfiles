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

# java
if [ -x "/usr/libexec/java_home" ]; then
  JAVA_HOME="$(/usr/libexec/java_home)"
  export JAVA_HOME
fi

# android
if [ -d "$HOME/android-sdk" ]; then
  export ANDROID_HOME="$HOME/android-sdk"
  export ANDROID_SDK="$ANDROID_HOME"
  export PATH="$ANDROID_SDK/tools/bin:$ANDROID_SDK/platform-tools:$ANDROID_SDK/ndk-bundle:$PATH"
fi

# fzf
if [ -x "$(command -v fd)" ]; then
  export FZF_DEFAULT_COMMAND='fd --type file --hidden'
elif [ -x "$(command -v rg)" ]; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden'
elif [ -x "$(command -v ag)" ]; then
  export FZF_DEFAULT_COMMAND='ag -g "" --hidden'
fi

# nvm
if [ -d "$HOME/.nvm" ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
fi

# rbenv
if [ -x "$(command -v rbenv)" ]; then
  eval "$(rbenv init -)"
fi

# rust
if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# golang
if [ -d "$HOME/go" ]; then
  export GOPATH="$HOME/go"
  if [ -d "$HOME/go/bin" ]; then
    export PATH="$HOME/go/bin:$PATH"
  fi
fi

# opam
if [ -f "$HOME/.opam/opam-init/init.sh" ]; then
  . "$HOME/.opam/opam-init/init.sh" 1>/dev/null 2>&1
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
