{ pkgs, ... }:
{
  home.packages = with pkgs; [
    playwright-test
  ];
}
