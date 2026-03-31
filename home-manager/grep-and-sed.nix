{ pkgs, ... }:
{
  programs.grep.enable = true;
  home.packages = with pkgs; [
    gnused
  ];
}
