{ pkgs, config, ... }:
let
  # Copies of the CJK fonts used in Emacs, patched to match JetBrains Mono NL:
  # 1. A full-width glyph is as wide as 2 glyphs of JetBrains Mono NL (1.2em).
  # 2. The line height is the same as JetBrains Mono NL.
  # 3. CoreText reports the font as monospace.
  #    In Emacs (NS build), a monospace font draws a glyph that is N times the space width
  #    exactly N space widths wide.
  # This keeps CJK glyphs aligned to 2 columns of JetBrains Mono NL at every font size,
  # including after text-scale-adjust, without face-font-rescale-alist.
  #
  # The fonts are renamed with the suffix RealMono, e.g. "Noto Sans Mono CJK HK RealMono",
  # so that the original fonts are still installed and usable.
  # See the subcommand patch-cjk-font in ./my-scripts/bin/font-utils.py for details.
  realmono-fonts =
    pkgs.runCommand "realmono-fonts"
      {
        nativeBuildInputs = [
          (pkgs."python${config.mypython.version}".withPackages (python-pkgs: [ python-pkgs.fonttools ]))
        ];
      }
      ''
        mkdir -p $out/share/fonts/opentype $out/share/fonts/truetype
        python ${./my-scripts/bin/font-utils.py} patch-cjk-font \
          --reference ${pkgs.jetbrains-mono}/share/fonts/truetype/JetBrainsMonoNL-Regular.ttf \
          --family-suffix RealMono \
          ${pkgs.noto-fonts-cjk-sans}/share/fonts/opentype/noto-cjk/NotoSansMonoCJK-VF.otf.ttc \
          $out/share/fonts/opentype/NotoSansMonoCJKRealMono-VF.otf.ttc
        python ${./my-scripts/bin/font-utils.py} patch-cjk-font \
          --reference ${pkgs.jetbrains-mono}/share/fonts/truetype/JetBrainsMonoNL-Regular.ttf \
          --family-suffix RealMono \
          ${pkgs.jigmo}/share/fonts/truetype/Jigmo.ttf \
          $out/share/fonts/truetype/JigmoRealMono.ttf
        python ${./my-scripts/bin/font-utils.py} patch-cjk-font \
          --reference ${pkgs.jetbrains-mono}/share/fonts/truetype/JetBrainsMonoNL-Regular.ttf \
          --family-suffix RealMono \
          ${pkgs.jigmo}/share/fonts/truetype/Jigmo2.ttf \
          $out/share/fonts/truetype/Jigmo2RealMono.ttf
        python ${./my-scripts/bin/font-utils.py} patch-cjk-font \
          --reference ${pkgs.jetbrains-mono}/share/fonts/truetype/JetBrainsMonoNL-Regular.ttf \
          --family-suffix RealMono \
          ${pkgs.jigmo}/share/fonts/truetype/Jigmo3.ttf \
          $out/share/fonts/truetype/Jigmo3RealMono.ttf
        python ${./my-scripts/bin/font-utils.py} patch-cjk-font \
          --reference ${pkgs.jetbrains-mono}/share/fonts/truetype/JetBrainsMonoNL-Regular.ttf \
          --family-suffix RealMono \
          ${pkgs.d2coding}/share/fonts/truetype/D2Coding-Ver1.4.0-20261003-all.ttc \
          $out/share/fonts/truetype/D2CodingRealMono-Ver1.4.0-20261003-all.ttc
      '';
in
{
  mypython.packages = [
    (python-pkgs: with python-pkgs; [ fonttools ])
  ];

  home.packages = with pkgs; [
    realmono-fonts

    # A variant of Courier
    courier-prime
    # Replacement of Arial, Times New Roman, and Courier New.
    liberation_ttf_v2

    # The original JetBrains Mono without Nerd Font patch.
    jetbrains-mono

    # A monospace font for coding with support for Hangul.
    d2coding

    # The Nerd Font (Symbols only).
    # It is used in Emacs because Emacs allows me to specify which font to use for
    # a particular Unicode code point range.
    # It is also used in Ghostty because Ghostty has `font-codepoint-map`.
    nerd-fonts.symbols-only

    # JuliaMono contains a lot of glyphs for symbols.
    julia-mono
    # This is a patched font with mahjong tile glyphs.
    gl-mahjongtile-clr
    # This font has very high CJK coverage.
    # https://kamichikoichi.github.io/jigmo/
    jigmo

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
