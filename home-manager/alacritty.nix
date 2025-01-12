{ config, ... }:
{
  programs.alacritty.enable = true;
  programs.alacritty.settings = {
    env = {
      # Study .tmux.conf before you change this.
      TERM = "alacritty";
    };
    general.import = [ ../.config/alacritty/dracula.toml ];
    terminal.shell = {
      program = "${config.home.profileDirectory}/bin/fish";
      args = [
        "--login"
        "--interactive"
      ];
    };
    font = {
      size = 13;
      normal = {
        family = "JetBrains Mono NL";
        style = "Light";
      };
      italic = {
        style = "Light Italic";
      };
      bold = {
        style = "Bold";
      };
      bold_italic = {
        style = "Bold Italic";
      };
    };
  };
}
