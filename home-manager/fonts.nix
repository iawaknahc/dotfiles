{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # JetBrains Mono can be recognized as fixed-width by macOS Font Book.
    #
    # Install the nerd-font variant of it so that I can use set it as
    # the default monospace in Firefox to show nerd font icons.
    (with nerd-fonts; jetbrains-mono)
    jetbrains-mono

    # Fonts by Adobe.
    source-serif
    source-serif-pro
    source-sans
    source-sans-pro
    source-code-pro
    source-han-sans
    source-han-serif
    # Although its name suggests it is monospace, it is not recognized by macOS as such.
    # See https://github.com/adobe-fonts/source-han-mono/issues/3
    # So it is not very useful, for example, you cannot use it in a terminal emulator.
    source-han-mono

    # Fonts by Google.
    # This package contains a lot of fonts.
    # But it does not include CJK fonts.
    noto-fonts
    # Thus, to install all noto fonts, we need to install the following 2 packages additionally.
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    # Emojis. It is not very useful on macOS as the Apple one will be used instead.
    noto-fonts-color-emoji
  ];
}
