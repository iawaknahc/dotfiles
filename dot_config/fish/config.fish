echo 'sourcing config.fish'

# Allow this file to be sourced more than once
# Both tmux and the shell sources this file.
# See https://superuser.com/questions/544989/does-tmux-sort-the-path-variable
if test -x /usr/libexec/path_helper
    set PATH ''
    # Cause path_helper to output csh commands.
    /usr/libexec/path_helper -c | source
end

# Add ~/.local/bin to PATH
fish_add_path -P "$HOME/.local/bin"

# Turn on vi mode
fish_vi_key_bindings

# Set locale
set -gx LANG en_US.UTF-8

# terminfo
# iTerm does not set TERMINFO automatically, so we help it here.
if [ "$TERM_PROGRAM" = "iTerm.app" ]
    if test -d "/Applications/iTerm.app/Contents/Resources/terminfo"
        set -gx TERMINFO "/Applications/iTerm.app/Contents/Resources/terminfo"
    end
end

# Set theme
fish_config theme choose MyDracula

# The rest of this file MUST BE sorted by the name of the section.
# The name of the section is the comment.

# android
# The default location of when Android Studio installs the SDK.
if test -d "$HOME/Library/Android/sdk"
    # ANDROID_SDK_ROOT is deprecated
    # https://developer.android.com/tools/variables
    set -gx ANDROID_HOME "$HOME/Library/Android/sdk"
    fish_add_path -P --append "$ANDROID_HOME/tools"
    fish_add_path -P --append "$ANDROID_HOME/tools/bin"
    # A binary sqlite3 lives here. So we want the binary provided by Android appear
    # at the end in PATH.
    fish_add_path -P --append "$ANDROID_HOME/platform-tools"
end

# delta
# I have tried it out for a day but I still prefer the good old diff.
# if test -x "$(command -v delta)"
#   set -gx GIT_PAGER delta
# end

# flutter
if test -d "$HOME/flutter"
    set -gx FLUTTER_ROOT "$HOME/flutter"
    fish_add_path -P "$FLUTTER_ROOT/bin"
    fish_add_path -P "$FLUTTER_ROOT/bin/cache/dart-sdk/bin"
    fish_add_path -P "$FLUTTER_ROOT/.pub-cache/bin"
end

# fzf
set -gx FZF_DEFAULT_COMMAND '
if git rev-parse --is-inside-work-tree
  git ls-files --cached --others --exclude-standard
else
  # In case fzf is run at / or HOME
  find . -type f -maxdepth 2
end
'

# golang
if test -x "$(command -v go)"
    set GOPATH "$(go env GOPATH)"
    fish_add_path -P "$GOPATH/bin"
end

# google-cloud-sdk
if test -f "$HOME/google-cloud-sdk/path.fish.inc"
    source "$HOME/google-cloud-sdk/path.fish.inc"
end

# homebrew
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
end
if test -x "$(command -v brew)"
    set HOMEBREW_PREFIX "$(brew --prefix)"

    if test -d "$HOMEBREW_PREFIX/opt/icu4c/lib/pkgconfig"
        set -gx PKG_CONFIG_PATH "$HOMEBREW_PREFIX/opt/icu4c/lib/pkgconfig"
    end

    set -gx CGO_CFLAGS "-I$HOMEBREW_PREFIX/include"
    set -gx CGO_LDFLAGS "-L$HOMEBREW_PREFIX/lib"
end

# kitty
if test -d "/Applications/kitty.app/Contents/MacOS"
    fish_add_path -P "/Applications/kitty.app/Contents/MacOS"
end

# nix
# For some unknown reason, this file is not executable.
if test -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish"
    source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish"
    # The above script use "fish_add_path --global", which writes to
    # $fish_user_paths.
    # I do not use $fish_user_paths so I have to repeat what the script does here.
    # But this time, with "fish_add_path -P".
    set -e fish_user_paths
    fish_add_path -P /nix/var/nix/profiles/default/bin
    fish_add_path -P "$HOME/.nix-profile/bin"
end

# nvim
set VIM vim
if test -x "$(command -v nvim)"
    set VIM nvim
    alias vi='nvim'
    alias vim='nvim'
    alias view='nvim -R'
    alias vimdiff='nvim -d'
    set -gx MANPAGER 'nvim +Man!'
end
set -gx VISUAL "$VIM"
set -gx EDITOR "$VIM"

# opam
if test -r "$HOME/.opam/opam-init/init.fish"
    source "$HOME/.opam/opam-init/init.fish"
end

# rust
if test -d "$HOME/.cargo"
    fish_add_path -P "$HOME/.cargo/bin"
end

# wezterm
if test -d "/Applications/WezTerm.app/Contents/MacOS"
    fish_add_path -P "/Applications/WezTerm.app/Contents/MacOS"
end

# asdf
# asdf must be the last one because it has to be appear earlier in PATH.
if test -r "$HOME/.asdf/asdf.fish"
    source "$HOME/.asdf/asdf.fish"
end
if test -r "$HOME/.asdf/completions/asdf.fish"
    source "$HOME/.asdf/completions/asdf.fish"
end
