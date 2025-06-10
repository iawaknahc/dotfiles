# zsh -i --login reads ALL files in this order: .zprofile .zshrc .zlogin
# zsh -i reads .zshrc

# No idea whether I need these things.
# Let's put them here first.
# Reduce ESC timeout
# export KEYTIMEOUT=1
# Make backspace able to delete any characters
# bindkey "^?" backward-delete-char
# Make CTRL-w able to delete the whole word
# bindkey "^W" backward-kill-word
{ lib, ... }:
{
  programs.zsh.enable = true;
  programs.zsh.defaultKeymap = "viins";
  programs.zsh.initContent = lib.mkBefore ''
    # Ensure SHELL is correctly set.
    # Note that this must appear after we have set up the PATH,
    # otherwise, `command -v zsh` points to a zsh that is not installed by Nix.
    export SHELL="$(command -v zsh)"
  '';
}
