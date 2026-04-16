{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gawk # provides awk
    nawk
    mawk
    awk-language-server
  ];
}
