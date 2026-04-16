{ pkgs, ... }:
{
  programs.java.enable = true;
  programs.java.package = with pkgs; temurin-bin;
  home.packages = with pkgs; [
    jdt-language-server
  ];
}
