{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nurl
    nix-melt
    flake-checker
  ];
  programs.nix-init.enable = true;
  programs.nh.enable = true;
}
