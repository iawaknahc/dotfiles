{ pkgs, ... }:
{
  home.packages = [ pkgs.bat ];
  xdg.configFile."bat" = {
    enable = true;
    recursive = true;
    source = ../.config/bat;
  };
}
