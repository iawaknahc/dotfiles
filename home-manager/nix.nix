{ pkgs, ... }:
{
  home.packages = with pkgs; [
    flake-checker
    nurl
    nix-melt
    nix-tree
  ];
  programs.nix-init.enable = true;
  programs.nh.enable = true;
}
