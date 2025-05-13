# When we were still using chezmoi, we use exact_conf.d/.gitkeep
# to make sure extra files in ~/.config/fish/conf.d/ are removed.
# That behavior can be replicated with home.activation.
{ pkgs, ... }:
let
  wrappers = import ./wrappers.nix { inherit pkgs; };
in
{
  programs.fish.enable = true;
  home.packages = with pkgs; [ babelfish ];
  programs.fish.shellInit = ''
    # Ensure SHELL is correctly set.
    # Note that this must appear after we have set up the PATH,
    # otherwise, `command -v fish` is an empty string.
    set --global --export SHELL "$(command -v fish)"
  '';
  programs.fish.interactiveShellInit = ''
    if status is-login
        echo "login shell: true"
    else
        echo "login shell: false"
    end

    echo "sourcing $(status filename)"
    # Turn on vi mode
    fish_vi_key_bindings
  '';
  xdg.configFile."fish/functions" = {
    enable = true;
    recursive = true;
    source = ../.config/fish/functions;
  };

  # When direnv-flake is used, very likely coreutils is added to PATH.
  # coreutils include a copy of ls.
  # That copy of ls is not smart enough to show color when being called interactively in a terminal.
  # When we call `ls`, the fish function named `ls` is invoked, instead of invoking
  # the copy of `ls` that comes with the direnv-flake coreutils.
  xdg.configFile."fish/functions/ls.fish" = {
    enable = true;
    text = ''
      function ls
        ${wrappers.ls} $argv
      end
    '';
  };
  xdg.configFile."fish/functions/grep.fish" = {
    enable = true;
    text = ''
      function grep
        ${wrappers.grep} $argv
      end
    '';
  };
  xdg.configFile."fish/functions/diff.fish" = {
    enable = true;
    text = ''
      function diff
        ${wrappers.diff} $argv
      end
    '';
  };
}
