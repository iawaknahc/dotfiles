{ pkgs, ... }:
{
  home.packages = with pkgs; [
    duckdb
    sqlite-interactive
  ];
}
