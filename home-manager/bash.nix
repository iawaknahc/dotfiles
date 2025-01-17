# bash -il reads the FIRST file in this order: .bash_profile .bash_login .profile
# bash -i reads .bashrc
{ pkgs, ... }:
{
  programs.bash.enable = true;
  home.packages = with pkgs; [ bash-completion ];
  programs.bash.bashrcExtra = ''
    if shopt -q login_shell; then
      echo "login shell: true"
    else
      echo "login shell: false"
    fi
    echo "sourcing $BASH_SOURCE"

    # Ensure SHELL is correctly set.
    # Note that this must appear after we have set up the PATH,
    # otherwise, `command -v bash` points to a bash that is not installed by Nix.
    export SHELL="$(command -v bash)"

    # Turn on vi mode
    set -o vi
  '';
  programs.bash.profileExtra = ''
    echo "sourcing .profile"
  '';
}
