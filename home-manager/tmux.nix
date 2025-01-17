{ pkgs, ... }:
{
  home.packages = with pkgs; [ tmux ];
  home.file.".tmux.conf" = {
    enable = true;
    source = ../.tmux.conf;
  };
}
