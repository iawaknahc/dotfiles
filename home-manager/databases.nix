{ pkgs, ... }:
{
  home.packages = [
    pkgs.duckdb
    pkgs.sqlite-interactive
  ];
}
