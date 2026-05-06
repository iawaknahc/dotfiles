{ pkgs, ... }:
{
  home.packages = with pkgs; [
    diffutils
    patch
  ];
}
