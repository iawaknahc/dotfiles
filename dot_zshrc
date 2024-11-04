# zsh -i --login reads ALL files in this order: .zprofile .zshrc .zlogin
# zsh -i reads .zshrc
# ==> .zshrc must source .profile

case "$-" in
  *l*) echo "login shell: true";;
  *) echo "login shell: false";;
esac

# man zshmisc and search for %N
# This is from https://stackoverflow.com/a/75564098
echo "sourcing ${(%):-%N}"

if [ -s "$HOME/.profile" ]; then
  . "$HOME/.profile"
fi

if [ -x "$(command -v direnv)" ]; then
  eval "$(direnv hook zsh)"
fi

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
