{ pkgs, ... }:
{
  home.packages = with pkgs; [
    flake-checker
    nil
    nix-melt
    nix-tree
    nix-unit
    nix-update
    nixfmt
    nurl
  ];
  programs.nix-init.enable = true;
  programs.nh.enable = true;
}
