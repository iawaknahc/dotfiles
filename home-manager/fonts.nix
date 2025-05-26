{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # JetBrains Mono can be recognized as fixed-width by macOS Font Book.
    #
    # Install the nert-font variant of it so that I can use set it as
    # the default monospace in Firefox to show nert font icons.
    (with nerd-fonts; jetbrains-mono)
    jetbrains-mono

    # CJK fonts
    source-han-sans
    source-han-serif
  ];
}
