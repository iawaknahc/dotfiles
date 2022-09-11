# bash -il reads the FIRST file in this order: .bash_profile .bash_login .profile
# bash -i reads .bashrc
# ==> .bash_profile and .bashrc must source .profile

# zsh -i --login reads ALL files in this order: .zprofile .zshrc .zlogin
# zsh -i reads .zshrc
# ==> .zshrc must source .profile

# Allow this file to be sourced more than once
# Both tmux and the shell sources this file.
# See https://superuser.com/questions/544989/does-tmux-sort-the-path-variable
if [ -r /etc/profile ]; then
  PATH=''
  . /etc/profile
fi

if [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Use nvim if it is installed
VIM=vim
if [ -x "$(command -v nvim)" ]; then
  VIM=nvim
  alias vi='nvim'
  alias vim='nvim'
  alias view='nvim -R'
  alias vimdiff='nvim -d'
fi
export VISUAL="$VIM"
export EDITOR="$VIM"

# Configure prompt
export PS1='$ '
export PS2='> '

# Set locale
# LANG=C.UTF-8 causes zsh not to display Unicode characters such as Japanese.
export LANG=en_US.UTF-8

# Turn on vi mode
set -o vi

# zsh
if [ -n "$ZSH_VERSION" ]; then
  # Reduce ESC timeout
  export KEYTIMEOUT=1
  # Make backspace able to delete any characters
  bindkey "^?" backward-delete-char
  # Make CTRL-w able to delete the whole word
  bindkey "^W" backward-kill-word
  # Enable native completion
  autoload compinit && compinit
  # Enable bash completion
  autoload bashcompinit && bashcompinit
fi

# android
if [ -d "/Users/louischan/Library/Android/sdk" ]; then
  export ANDROID_SDK_ROOT="/Users/louischan/Library/Android/sdk"
  export ANDROID_HOME="$ANDROID_SDK_ROOT"
  export PATH="$ANDROID_SDK_ROOT/tools:$PATH"
  export PATH="$ANDROID_SDK_ROOT/tools/bin:$PATH"
  export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
fi

# fzf
export FZF_DEFAULT_COMMAND='
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git ls-files --cached --others --exclude-standard
else
  # In case fzf is run at / or HOME
  find . -type f -maxdepth 2
fi
'

# rust
if [ -d "$HOME/.cargo" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# golang
if [ -x "$(command -v go)" ]; then
  GOPATH="$(go env GOPATH)"
  export PATH="$GOPATH/bin:$PATH"
fi

# mason
if [ -d "$HOME/.local/share/nvim/mason/bin" ]; then
  export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
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
if [ -r "$HOME/.opam/opam-init/init.sh" ]; then
  . >/dev/null 2>&1 "$HOME/.opam/opam-init/init.sh"
fi

# asdf
if [ -r "$HOME"/.asdf/asdf.sh ]; then
  . "$HOME"/.asdf/asdf.sh
fi
if [ -r "$HOME"/.asdf/completions/asdf.bash ]; then
  . "$HOME"/.asdf/completions/asdf.bash
fi

if [ -x "$(command -v brew)" ]; then
  BREW_PREFIX="$(brew --prefix)"
  if [ -d "$BREW_PREFIX/opt/icu4c/lib/pkgconfig" ]; then
    export PKG_CONFIG_PATH="$BREW_PREFIX/opt/icu4c/lib/pkgconfig"
  fi

  # Make libraries installed by homebrew visible to Cgo.
  export CGO_CFLAGS="-I$(brew --prefix)/include"
  export CGO_LDFLAGS="-L$(brew --prefix)/lib"

  # bash
  if [ -n "$BASH_VERSION" ]; then
    # Enable bash completion
    # If bash-completion is >= 2, then we need to define BASH_COMPLETION_COMPAT_DIR
    # in order to use existing completions.
    # bash-completion@2 requires bash >= 4, use chsh to change login shell.
    export BASH_COMPLETION_COMPAT_DIR="$BREW_PREFIX/etc/bash_completion.d"
    [ -r "$BREW_PREFIX/etc/profile.d/bash_completion.sh" ] && . "$BREW_PREFIX/etc/profile.d/bash_completion.sh"
  fi
fi
