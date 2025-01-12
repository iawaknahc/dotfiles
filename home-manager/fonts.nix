{ pkgs, ... }:
{
  home.packages = [
    # This one is recognized as fixed-width.
    pkgs.jetbrains-mono

    # CJK fonts
    pkgs.source-han-sans
    pkgs.source-han-serif
  ];
}
