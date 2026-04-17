# When we were still using chezmoi, we use exact_conf.d/.gitkeep
# to make sure extra files in ~/.config/fish/conf.d/ are removed.
# That behavior can be replicated with home.activation.
{ pkgs, ... }:
{
  programs.fish.enable = true;
  home.packages = with pkgs; [
    babelfish
    fish-lsp
  ];
  programs.fish.shellInit = ''
    # Ensure SHELL is correctly set.
    # Note that this must appear after we have set up the PATH,
    # otherwise, `command -v fish` is an empty string.
    set --global --export SHELL "$(command -v fish)"
  '';
  programs.fish.interactiveShellInit = ''
    # In preparation for using neovim as default terminal program,
    # we disable vi mode in shell.
    # fish_vi_key_bindings
  '';

  # fish is known for creating fish functions to shadow some common utilties:
  # - https://github.com/fish-shell/fish-shell/blob/4.6.0/share/functions/cd.fish
  # - https://github.com/fish-shell/fish-shell/blob/4.6.0/share/functions/diff.fish
  # - https://github.com/fish-shell/fish-shell/blob/4.6.0/share/functions/grep.fish
  # - https://github.com/fish-shell/fish-shell/blob/4.6.0/share/functions/la.fish
  # - https://github.com/fish-shell/fish-shell/blob/4.6.0/share/functions/ll.fish
  # - https://github.com/fish-shell/fish-shell/blob/4.6.0/share/functions/ls.fish
  #
  # Since we now use eza, ls, ll, la from fish are overridden by the aliases defined by eza shell integration.
  # Since we now use zoxide, cd is overridden by the aliases defined by zoxide shell integration.
  # The remaining diff and grep are not harmful, so just leave them.

  xdg.configFile."fish/functions" = {
    enable = true;
    recursive = true;
    source = ../.config/fish/functions;
  };
}
