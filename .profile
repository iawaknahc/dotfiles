# https://superuser.com/questions/544989/does-tmux-sort-the-path-variable
if [ -r /etc/profile ]; then
  PATH=''
  . /etc/profile
fi

# Use nvim if it is installed
if [ -x "$(command -v nvim)" ]; then
  VIM=nvim
  alias vi='nvim'
  alias vim='nvim'
  alias view='nvim -R'
  alias vimdiff='nvim -d'
else
  VIM=vim
fi

export VISUAL="$VIM"
export EDITOR="$VISUAL"
export PS1='$ '
export PS2='> '
export LANG=en_US.UTF-8

set -o vi

replace() {
  # https://github.com/BurntSushi/ripgrep/blob/master/FAQ.md#search-and-replace
  # This is a command that combine rg and sed to perform search-and-replace.
  if [ ! -x "$(command -v rg)" ]; then
    echo 1>&2 'rg is not in PATH'
    return 1
  fi
  pattern="$(printf '%s' "$1" | sed 's/\//\\\//g')"
  replacement="$(printf '%s' "$2" | sed 's/\//\\\//g')"
  rg "$1" --files-with-matches -0 | xargs -0 sed -i '' "s/$pattern/$replacement/g"
}

backup_macos() {
  COPYFILE_DISABLE=true tar czf "$1" -C "$HOME" Library/Keychains .ssh .gnupg
}

# android
if [ -d "/usr/local/share/android-sdk" ]; then
  export ANDROID_SDK_ROOT="/usr/local/share/android-sdk"
  export ANDROID_HOME="$ANDROID_SDK_ROOT"
  export PATH="$ANDROID_SDK_ROOT/tools:$PATH"
  export PATH="$ANDROID_SDK_ROOT/tools/bin:$PATH"
  export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
fi

# fzf
if [ -x "$(command -v fd)" ]; then
  export FZF_DEFAULT_COMMAND='fd --type file'
elif [ -x "$(command -v rg)" ]; then
  export FZF_DEFAULT_COMMAND='rg --files'
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
[ -r "$HOME/.opam/opam-init/init.sh" ] && . >/dev/null 2>&1 "$HOME/.opam/opam-init/init.sh" || true

# brew specific
if [ -x "$(command -v brew)" ]; then
  # bash specific
  if [ "$(basename "$SHELL")" = bash ]; then
    # Enable bash completion
    # If bash-completion is >= 2, then we need to define BASH_COMPLETION_COMPAT_DIR
    # in order to use existing completions.
    # bash-completion@2 requires bash >= 4, use chsh to change login shell.
    export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
    [ -r "/usr/local/etc/profile.d/bash_completion.sh" ] && . "/usr/local/etc/profile.d/bash_completion.sh"
  fi
fi

# asdf
if [ -r "$HOME"/.asdf/asdf.sh ]; then
  . "$HOME"/.asdf/asdf.sh
fi
if [ -r "$HOME"/.asdf/completions/asdf.bash ]; then
  . "$HOME"/.asdf/completions/asdf.bash
fi
