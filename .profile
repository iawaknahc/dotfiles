# https://superuser.com/questions/544989/does-tmux-sort-the-path-variable
if [ -r /etc/profile ]; then
  PATH=''
  . /etc/profile
fi

export VISUAL=vim
export EDITOR="$VISUAL"
export PS1='$ '
export PS2='> '
export LC_ALL=en_US.UTF-8

set -o vi

alias lisp='rlwrap sbcl'

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
[ -r "$HOME/.opam/opam-init/init.sh" ] && . >/dev/null 2>&1 "$HOME/.opam/opam-init/init.sh" || true

# ruby/gem
# ruby installed from brew is not symlinked to /usr/local/bin
# See brew info ruby for more details.

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

# vg
# This must be the last thing otherwise
# vg deactivate will wipe out the preceding items in PATH
if [ -x "$(command -v vg)" ]; then
  eval "$(vg eval --shell bash)"
fi
