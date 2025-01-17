{ pkgs, ... }:
{
  home.packages = with pkgs; [ delta ];
  xdg.configFile."delta" = {
    enable = true;
    recursive = true;
    source = ../.config/delta;
  };
}
