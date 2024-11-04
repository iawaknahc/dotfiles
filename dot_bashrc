if shopt -q login_shell; then
  echo "login shell: true"
else
  echo "login shell: false"
fi

echo "sourcing $BASH_SOURCE"

if [ -s "$HOME/.profile" ]; then
  . "$HOME/.profile"
fi

if [ -x "$(command -v direnv)" ]; then
  eval "$(direnv hook bash)"
fi
