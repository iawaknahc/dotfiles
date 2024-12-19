echo "sourcing .profile"

before_set_path() {
  # Turn on vi mode
  set -o vi

  # Configure prompt
  export PS1="[$SHLVL] \$ "
  export PS2='> '
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

  # The rest of this file MUST BE sorted by the name of the section.
  # The name of the section is the comment.

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
  if [ -x "$(command -v nvim)" ]; then
    alias vi='nvim'
    alias vim='nvim'
    alias view='nvim -R'
    alias vimdiff='nvim -d'
  fi
}

before_set_path
if [ -z "$IN_NIX_SHELL" ]; then
  set_path
fi
after_set_path
