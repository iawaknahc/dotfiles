{ pkgs, ... }:
{
  programs.jq.enable = true;
  home.packages = with pkgs; [
    jo # https://github.com/jpmens/jo
    yq-go
  ];
}
