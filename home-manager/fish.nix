# When we were still using chezmoi, we use exact_conf.d/.gitkeep
# to make sure extra files in ~/.config/fish/conf.d/ are removed.
# That behavior can be replicated with home.activation.
{ pkgs, ... }:
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

    # Set theme
    fish_config theme choose MyDracula
  '';
  xdg.configFile."fish/themes" = {
    enable = true;
    recursive = true;
    source = ../.config/fish/themes;
  };
  xdg.configFile."fish/functions" = {
    enable = true;
    recursive = true;
    source = ../.config/fish/functions;
  };
}
