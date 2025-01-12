{ pkgs, ... }:
{
  home.packages = [ pkgs.git ];
  xdg.configFile."git" = {
    enable = true;
    recursive = true;
    source = ../.config/git;
  };
}
