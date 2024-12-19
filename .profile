echo "sourcing .profile"

before_set_path() {
  # Turn on vi mode
  set -o vi

  # Set locale
  # LANG=C.UTF-8 causes zsh not to display Unicode characters such as Japanese.
  export LANG=en_US.UTF-8

  # Configure prompt
  export PS1="[$SHLVL] \$ "
  export PS2='> '

  # delta
  # I have tried it out for a day but I still prefer the good old diff.
  # if [ -x "$(command -v delta)" ]; then
  #   export GIT_PAGER='delta'
  # fi

  # ripgrep
  if [ -r "$HOME/.config/ripgrep/ripgreprc" ]; then
    export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"
  fi

  # terminfo
  # iTerm does not set TERMINFO automatically, so we help it here.
  if [ "$TERM_PROGRAM" = "iTerm.app" ]; then
    if [ -d "/Applications/iTerm.app/Contents/Resources/terminfo" ]; then
      export TERMINFO="/Applications/iTerm.app/Contents/Resources/terminfo"
    fi
  fi
}

set_path() {
  # We used to reset PATH to an empty string here.
  # With
  # 1. In iTerm.app, set shell to Custom Shell. This means $SHELL is correct.
  # 2. With tmux 3.5a, the default-command is left unset.
  # Then when open a new tmux window, the shell is only sourced once.

  # nix
  if [ -r "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
    . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

    # nix and bash
    if [ -n "$BASH_VERSION" ]; then
      # Enable bash completion
      if [ -r "$HOME/.nix-profile/share/bash-completion/bash_completion" ]; then
        . "$HOME/.nix-profile/share/bash-completion/bash_completion"
      fi
    fi
  fi

  # home-manager
  if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
  fi

  # Add ~/.local/bin to PATH
  export PATH="$HOME/.local/bin:$PATH"

  # The rest of this file MUST BE sorted by the name of the section.
  # The name of the section is the comment.

  # android
  # The default location of when Android Studio installs the SDK.
  if [ -d "$HOME/Library/Android/sdk" ]; then
    # ANDROID_SDK_ROOT is deprecated
    # https://developer.android.com/tools/variables
    export ANDROID_HOME="$ANDROID_SDK_ROOT"
    export PATH="$PATH:$ANDROID_SDK_ROOT/tools"
    export PATH="$PATH:$ANDROID_SDK_ROOT/tools/bin"
    # A binary sqlite3 lives here. So we want the binary provided by Android appear
    # at the end in PATH.
    export PATH="$PATH:$ANDROID_SDK_ROOT/platform-tools"
  fi

  # flutter
  if [ -d "$HOME/flutter" ]; then
    export FLUTTER_ROOT="$HOME/flutter"
    # Make flutter available
    export PATH="$HOME/flutter/bin:$PATH"
    # Make the executables of embedded dark-sdk, say dartfmt, available
    export PATH="$HOME/flutter/bin/cache/dart-sdk/bin:$PATH"
    # Make executables installed with `flutter packages pub global activate` available
    # Notably, we want to run `flutter packages pub global activate dart_language_server`
    export PATH="$HOME/flutter/.pub-cache/bin:$PATH"
  fi

  # golang
  # I no longer install go system-wide.
  # If go is installed with asdf, then the binaries installed with `go install` are made
  # available with `asdf reshim`.
  # if [ -x "$(command -v go)" ]; then
  #   GOPATH="$(go env GOPATH)"
  #   export PATH="$GOPATH/bin:$PATH"
  # fi

  # google-cloud-sdk
  if [ -d "$HOME/google-cloud-sdk" ]; then
    # If you have read the source code of "$HOME/google-cloud-sdk/path.bash.inc",
    # you can see that all it does is add google-cloud-sdk/bin to PATH.
    # So we do that ourselves here.
    export PATH="$HOME/google-cloud-sdk/bin:$PATH"
  fi

  # homebrew
  if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  if [ -x "$(command -v brew)" ]; then
    if [ -d "$HOMEBREW_PREFIX/opt/icu4c/lib/pkgconfig" ]; then
      export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/opt/icu4c/lib/pkgconfig"
    fi

    # Make libraries installed by homebrew visible to Cgo.
    export CGO_CFLAGS="-I$(brew --prefix)/include"
    export CGO_LDFLAGS="-L$(brew --prefix)/lib"

    # homebrew and bash
    if [ -n "$BASH_VERSION" ]; then
      # Enable bash completion
      # If bash-completion is >= 2, then we need to define BASH_COMPLETION_COMPAT_DIR
      # in order to use existing completions.
      # bash-completion@2 requires bash >= 4, use chsh to change login shell.
      export BASH_COMPLETION_COMPAT_DIR="$HOMEBREW_PREFIX/etc/bash_completion.d"
      [ -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ] && . "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
    fi
  fi

  # kitty
  if [ -d "/Applications/kitty.app/Contents/MacOS" ]; then
    export PATH="/Applications/kitty.app/Contents/MacOS:$PATH"
  fi

  # opam
  if [ -r "$HOME/.opam/opam-init/init.sh" ]; then
    . >/dev/null 2>&1 "$HOME/.opam/opam-init/init.sh"
  fi

  # rust
  if [ -d "$HOME/.cargo" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
  fi

  # wezterm
  if [ -d "/Applications/WezTerm.app/Contents/MacOS" ]; then
    export PATH="/Applications/WezTerm.app/Contents/MacOS:$PATH"
  fi

  # asdf
  # asdf must be the last one because it has to be appear earlier in PATH.
  if [ -r "$HOME"/.asdf/asdf.sh ]; then
    . "$HOME"/.asdf/asdf.sh

    # asdf and bash
    if [ -n "$BASH_VERSION" ]; then
      if [ -r "$HOME"/.asdf/completions/asdf.bash ]; then
        . "$HOME"/.asdf/completions/asdf.bash
      fi
    fi
  fi
}

after_set_path() {
  # nvim
  VIM=vim
  if [ -x "$(command -v nvim)" ]; then
    VIM=nvim
    alias vi='nvim'
    alias vim='nvim'
    alias view='nvim -R'
    alias vimdiff='nvim -d'
    export MANPAGER='nvim +Man!'
  fi
  export VISUAL="$VIM"
  export EDITOR="$VIM"
}

before_set_path
if [ -z "$IN_NIX_SHELL" ]; then
  set_path
fi
after_set_path
