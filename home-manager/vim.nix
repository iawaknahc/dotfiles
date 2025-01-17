{ pkgs, ... }:
{
  # The home-manager module programs.vim does not write $HOME/.vimrc.
  # So I did not use it.
  home.packages = with pkgs; [ vim-full ];
  home.file.".vimrc".source = ../.vimrc;
}
