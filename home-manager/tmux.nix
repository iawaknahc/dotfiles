{ pkgs, ... }:
{
  home.packages = [ pkgs.tmux ];
  home.file.".tmux.conf" = {
    enable = true;
    source = ../.tmux.conf;
  };
}
