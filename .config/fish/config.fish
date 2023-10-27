# Allow this file to be sourced more than once
# Both tmux and the shell sources this file.
# See https://superuser.com/questions/544989/does-tmux-sort-the-path-variable
if test -x /usr/libexec/path_helper
  set PATH ''
  # Cause path_helper to output csh commands.
  /usr/libexec/path_helper -c | source
end

# Turn on vi mode
fish_vi_key_bindings

# Set locale
set -gx LANG en_US.UTF-8

# Set theme
fish_config theme choose "Dracula Official"

# The rest of this file MUST BE sorted by the name of the section.
# The name of the section is the comment.

# android
if test -d "$HOME/Library/Android/sdk"
  set -gx ANDROID_SDK_ROOT "$HOME/Library/Android/sdk"
  set -gx ANDROID_HOME "$ANDROID_SDK_ROOT"
  fish_add_path -P "$ANDROID_SDK_ROOT/tools"
  fish_add_path -P "$ANDROID_SDK_ROOT/tools/bin"
  fish_add_path -P "$ANDROID_SDK_ROOT/platform-tools"
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
if rev-parse --is-inside-work-tree >/dev/null 2>&1
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

# mason
if test -d "$HOME/.local/share/nvim/mason/bin"
  fish_add_path -P "$HOME/.local/share/nvim/mason/bin"
end

# nvim
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

# opam
if test -r "$HOME/.opam/opam-init/init.fish"
  source "$HOME/.opam/opam-init/init.fish"
end

# python
if test -x "$(command -v python3)"
  alias jsontool='python3 -m json.tool --no-ensure-ascii'
  alias percent_encode_path_segment='python3 -c \'import sys,urllib.parse as u;[print(u.quote(l,safe=\\\':@$&+=\\\'))for l in sys.stdin.read().splitlines()]\''
  alias percent_decode_path_segment='python3 -c \'import sys,urllib.parse as u;[print(u.unquote(l))for l in sys.stdin.read().splitlines()]\''
  alias percent_encode_query_component='python3 -c \'import sys,urllib.parse as u;[print(u.quote_plus(l))for l in sys.stdin.read().splitlines()]\''
  alias percent_decode_query_component='python3 -c \'import sys,urllib.parse as u;[print(u.unquote_plus(l))for l in sys.stdin.read().splitlines()]\''
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

# sqlite3
# sqlite3 must appear AFTER android because ANDROID_SDK_ROOT/platform-tools
# contains an ancient copy of sqlite3.
if test -x "$(command -v brew)"
  if test -x "$(brew --prefix)/opt/sqlite3/bin/sqlite3"
    fish_add_path -P "$(brew --prefix)/opt/sqlite3/bin"
  end
end
