# bash -il reads the FIRST file in this order: .bash_profile .bash_login .profile
# bash -i reads .bashrc
# ==> .bash_profile and .bashrc must source .profile
#
# We make .bash_profile source .bashrc

if [ -s "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
