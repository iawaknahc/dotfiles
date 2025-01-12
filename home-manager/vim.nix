{ pkgs, ... }:
{
  home.packages = [ pkgs.vim ];
  home.file.".vimrc" = {
    enable = true;
    source = ../.vimrc;
  };
}
