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
{ ... }:
{
  programs.zsh.enable = true;
  programs.zsh.defaultKeymap = "viins";
  programs.zsh.initExtraFirst = ''
    case "$-" in
      *l*) echo "login shell: true";;
      *) echo "login shell: false";;
    esac

    # man zshmisc and search for %N
    # This is from https://stackoverflow.com/a/75564098
    echo "sourcing ''${(%):-%N}"

    # Ensure SHELL is correctly set.
    # Note that this must appear after we have set up the PATH,
    # otherwise, `command -v zsh` points to a zsh that is not installed by Nix.
    export SHELL="$(command -v zsh)"
  '';
}
