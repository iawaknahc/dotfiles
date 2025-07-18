# bash -il reads the FIRST file in this order: .bash_profile .bash_login .profile
# bash -i reads .bashrc
{ pkgs, ... }:
{
  programs.bash.enable = true;
  home.packages = with pkgs; [
    bash-completion
    # On 2025-03-01, I tried ble.sh. It was 0.4.0-devel3
    # It did not work well for me, for the following reasons:
    #
    # 1. The vi mode setup was documented at GitHub Wiki, so it was hard to view the
    #    documentation that was applicable to 0.4.0-devel3
    #    I had mode shown with Starship so I wanted to disable the mode line,
    #    but the poor documentation did not allow me to do so.
    # 2. The highlight used colors other than my terminal colors. I did not like this behavior.
    blesh
  ];
  programs.bash.bashrcExtra = ''
    # Ensure SHELL is correctly set.
    # Note that this must appear after we have set up the PATH,
    # otherwise, `command -v bash` points to a bash that is not installed by Nix.
    export SHELL="$(command -v bash)"

    # In preparation for using neovim as default terminal program,
    # we disable vi mode in shell.
    # set -o vi
  '';
}
