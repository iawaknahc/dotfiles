# bash -il reads the FIRST file in this order: .bash_profile .bash_login .profile
# bash -i reads .bashrc
# ==> .bash_profile and .bashrc must source .profile

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
