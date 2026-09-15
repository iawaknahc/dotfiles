{ pkgs, ... }:
{
  home.packages = with pkgs; [
    melonds
  ];
}
