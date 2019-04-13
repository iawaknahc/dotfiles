# https://superuser.com/questions/544989/does-tmux-sort-the-path-variable
if [ -f /etc/profile ]; then
  PATH=''
  . /etc/profile
fi

export VISUAL=vim
export EDITOR="$VISUAL"
export PS1='$ '
export PS2='> '
export LC_ALL=en_US.UTF-8
set -o vi

replace() {
  # https://github.com/BurntSushi/ripgrep/blob/master/FAQ.md#search-and-replace
  # This is a command that combine rg and sed to perform search-and-replace.
  if [ ! -x "$(command -v rg)" ]; then
    1>&2 echo 'rg is not in PATH'
    return 1
  fi
  pattern="$(printf '%s' "$1" | sed 's/\//\\\//g')"
  replacement="$(printf '%s' "$2" | sed 's/\//\\\//g')"
  rg "$1" --files-with-matches -0 | xargs -0 sed -i '' "s/$pattern/$replacement/g"
}

backup_macos() {
  COPYFILE_DISABLE=true tar czf "$1" -C "$HOME" Library/Keychains .ssh .gnupg
}

g() {
  GIT_DIR="$HOME/.dotfiles.git" GIT_WORK_TREE="$HOME" git "$@"
}

# android
if [ -d "$HOME/Library/Android/sdk" ]; then
  export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
  export ANDROID_HOME="$ANDROID_SDK_ROOT"
  export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
  export PATH="$ANDROID_SDK_ROOT/tools/bin:$PATH"
fi

# fzf
if [ -x "$(command -v fd)" ]; then
  export FZF_DEFAULT_COMMAND='fd --type file'
elif [ -x "$(command -v rg)" ]; then
  export FZF_DEFAULT_COMMAND='rg --files'
fi

# golang
if [ -d "$HOME/go" ]; then
  export GOPATH="$HOME/go"
  export PATH="$GOPATH/bin:$PATH"
fi

# rust
if [ -d "$HOME/.cargo" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# flutter
if [ -d "$HOME/flutter" ]; then
  # Make flutter available
  export PATH="$HOME/flutter/bin:$PATH"
  # Make the executables of embedded dark-sdk, say dartfmt, available
  export PATH="$HOME/flutter/bin/cache/dart-sdk/bin:$PATH"
  # Make executables installed with `flutter packages pub global activate` available
  # Notably, we want to run `flutter packages pub global activate dart_language_server`
  export PATH="$HOME/flutter/.pub-cache/bin:$PATH"
fi

# opam
[ -r "$HOME/.opam/opam-init/init.sh" ] && >/dev/null 2>&1 . "$HOME/.opam/opam-init/init.sh" || true

# gem
if [ -x "$(command -v gem)" ]; then
  export PATH="$(gem env gemdir)/bin:$PATH"
fi

# brew specific
if [ -x "$(command -v brew)" ]; then
  # bash specific
  if [ "$(basename "$SHELL")" = bash ]; then
    # enable bash completion
    [ -f "$(brew --prefix)/etc/bash_completion" ] && . "$(brew --prefix)/etc/bash_completion"
  fi
fi
