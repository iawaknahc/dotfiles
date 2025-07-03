{ pkgs, ... }:
{
  home.packages = with pkgs; [
    unicode-character-database
    # This program is known to be broken on nixpkgs
    # See https://github.com/NixOS/nixpkgs/pull/420887
    unicode-paracode
  ];
  home.file.".unicode" = {
    source = "${pkgs.unicode-character-database}/share/unicode";
    recursive = true;
  };
}
