{ pkgs, ... }:
{
  programs.java.enable = true;
  programs.java.package = with pkgs; temurin-bin;
}
