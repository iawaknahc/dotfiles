{ pkgs, ... }:
{
  mypython.packages = [
    (python-pkgs: with python-pkgs; [ fonttools ])
  ];

  home.packages = with pkgs; [
    # A variant of Courier
    courier-prime
    # Replacement of Arial, Times New Roman, and Courier New.
    liberation_ttf_v2

    # The original JetBrains Mono without Nerd Font patch.
    jetbrains-mono

    # The Nerd Font (Symbols only).
    # It is used in Emacs because Emacs allows me to specify which font to use for
    # a particular Unicode code point range.
    # It is also used in Ghostty because Ghostty has `font-codepoint-map`.
    nerd-fonts.symbols-only

    # Fonts by Adobe.
    source-serif
    source-serif-pro
    source-sans
    source-sans-pro
    source-code-pro
    source-han-sans
    source-han-serif
    # I used to install Source Han Mono 1.002
    # But it cannot be recognized as monospace font on macOS,
    # no matter how do we patch it with fonttools.
    # Technically it is Source Code Pro combined with Source Han Sans.
    # It is trivial to use Source Han Sans in Emacs because
    # Emacs does not really care if it is a monospace font.

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
