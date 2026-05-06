{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pax
    gnutar
    gzip
    bzip2
    unzip
    zip
    xz
  ];
}
