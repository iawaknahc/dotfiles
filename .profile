export VISUAL='vim'
export EDITOR="$VISUAL"
export PS1='$ '
export PS2='> '
export LC_ALL='en_US.UTF-8'

if [ -x "/usr/libexec/java_home" ]; then
  JAVA_HOME="$(/usr/libexec/java_home)"
  export JAVA_HOME
fi

if [ -d "$HOME/android-sdk" ]; then
  export ANDROID_HOME="$HOME/android-sdk"
  export ANDROID_SDK="$ANDROID_HOME"
  export PATH="$ANDROID_SDK/tools/bin:$ANDROID_SDK/platform-tools:$ANDROID_SDK/ndk-bundle:$PATH"
fi

if [ -x "$(command -v ag)" ]; then
  export FZF_DEFAULT_COMMAND='ag -g ""'
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

if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# golang
export GOPATH="$HOME/go"
if [ -d "$HOME/go/bin" ]; then
  export PATH="$HOME/go/bin:$PATH"
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

replace() {
  pattern=$(echo "$1" | perl -pe 's/\//\\\//g')
  replacement=$(echo "$2" | perl -pe 's/\//\\\//g')
  ag -0ls "$pattern" | xargs -0 perl -pi -e "s/$pattern/$replacement/g"
}

if [ -d "$HOME/.dotfiles.git" ]; then
  alias dotfiles='git --git-dir="$HOME/.dotfiles.git" --work-tree="$HOME"'
fi
