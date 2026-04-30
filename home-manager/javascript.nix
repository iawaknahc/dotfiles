{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bun
    deno
    nodejs
    yarn
  ];
}
