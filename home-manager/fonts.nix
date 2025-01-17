{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # This one is recognized as fixed-width.
    jetbrains-mono

    # CJK fonts
    source-han-sans
    source-han-serif
  ];
}
