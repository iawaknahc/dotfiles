# `zsh -i --login` reads ALL files in this order: .zprofile .zshrc .zlogin
# `zsh -i` reads .zshrc

{ lib, ... }:
{
  programs.zsh.enable = true;
  # In preparation for using neovim as default terminal program,
  # we disable vi mode in shell.
  # programs.zsh.defaultKeymap = "viins";
  programs.zsh.initContent = lib.mkBefore ''
    # Ensure SHELL is correctly set.
    # Note that this must appear after we have set up the PATH,
    # otherwise, `command -v zsh` points to a zsh that is not installed by Nix.
    export SHELL="$(command -v zsh)"
  '';
}
