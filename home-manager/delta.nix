{ pkgs, ... }:
{
  home.packages = [ pkgs.delta ];
  xdg.configFile."delta" = {
    enable = true;
    recursive = true;
    source = ../.config/delta;
  };
}
