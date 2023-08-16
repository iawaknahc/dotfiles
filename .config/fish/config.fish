if test -x /usr/libexec/path_helper
  set PATH ''
  # Cause path_helper to output csh commands.
  /usr/libexec/path_helper -c | source
end

if test -x /opt/homebrew/bin/brew
  /opt/homebrew/bin/brew shellenv | source
end

set VIM vim
if test -x "$(command -v nvim)"
  set VIM nvim
  alias vi='nvim'
  alias vim='nvim'
  alias view='nvim -R'
  alias vimdiff='nvim -d'
end
set -gx VISUAL "$VIM"
set -gx EDITOR "$VIM"

fish_vi_key_bindings

set -gx LANG en_US.UTF-8

set -gx FZF_DEFAULT_COMMAND '
if rev-parse --is-inside-work-tree >/dev/null 2>&1
  git ls-files --cached --others --exclude-standard
else
  # In case fzf is run at / or HOME
  find . -type f -maxdepth 2
end
'

if test -d "/Applications/kitty.app/Contents/MacOS"
  fish_add_path -P "/Applications/kitty.app/Contents/MacOS"
end

if test -d "/Applications/WezTerm.app/Contents/MacOS"
  fish_add_path -P "/Applications/WezTerm.app/Contents/MacOS"
end

if test -d "$HOME/Library/Android/sdk"
  set -gx ANDROID_SDK_ROOT "$HOME/Library/Android/sdk"
  set -gx ANDROID_HOME "$ANDROID_SDK_ROOT"
  fish_add_path -P "$ANDROID_SDK_ROOT/tools"
  fish_add_path -P "$ANDROID_SDK_ROOT/tools/bin"
  fish_add_path -P "$ANDROID_SDK_ROOT/platform-tools"
end

if test -d "$HOME/.cargo"
  fish_add_path -P "$HOME/.cargo/bin"
end

if test -x "$(command -v go)"
  set GOPATH "$(go env GOPATH)"
  fish_add_path -P "$GOPATH/bin"
end

if test -d "$HOME/.local/share/nvim/mason/bin"
  fish_add_path -P "$HOME/.local/share/nvim/mason/bin"
end

if test -d "$HOME/flutter"
  set -gx FLUTTER_ROOT "$HOME/flutter"
  fish_add_path -P "$FLUTTER_ROOT/bin"
  fish_add_path -P "$FLUTTER_ROOT/bin/cache/dart-sdk/bin"
  fish_add_path -P "$FLUTTER_ROOT/.pub-cache/bin"
end

if test -r "$HOME/.opam/opam-init/init.fish"
  source "$HOME/.opam/opam-init/init.fish"
end

if test -r "$HOME/.asdf/asdf.fish"
  source "$HOME/.asdf/asdf.fish"
end
if test -r "$HOME/.asdf/completions/asdf.fish"
  source "$HOME/.asdf/completions/asdf.fish"
end

if test -x "$(command -v brew)"
  set HOMEBREW_PREFIX "$(brew --prefix)"

  if test -d "$HOMEBREW_PREFIX/opt/icu4c/lib/pkgconfig"
    set -gx PKG_CONFIG_PATH "$HOMEBREW_PREFIX/opt/icu4c/lib/pkgconfig"
  end

  set -gx CGO_CFLAGS "-I$HOMEBREW_PREFIX/include"
  set -gx CGO_LDFLAGS "-L$HOMEBREW_PREFIX/lib"
end

fish_config theme choose "Dracula Official"
