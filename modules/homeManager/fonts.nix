{ pkgs, config, ... }:
let
  # Copies of Noto Sans Mono CJK and Jigmo that CoreText reports as monospace.
  # In Emacs (NS build), a monospace font draws a glyph that is N times the space width
  # exactly N space widths wide.
  # Together with a rescale ratio of 1.2, this keeps CJK glyphs aligned to 2 columns
  # of JetBrains Mono at every font size, including after text-scale-adjust.
  #
  # The fonts are renamed with the suffix RealMono, e.g. "Noto Sans Mono CJK HK RealMono",
  # so that the original fonts are still installed and usable.
  # See ./fonts/patch_fixed_pitch.py for details.
  realmono-fonts =
    pkgs.runCommand "realmono-fonts"
      {
        nativeBuildInputs = [
          (pkgs."python${config.mypython.version}".withPackages (python-pkgs: [ python-pkgs.fonttools ]))
        ];
      }
      ''
        mkdir -p $out/share/fonts/opentype $out/share/fonts/truetype
        python ${./fonts/patch_fixed_pitch.py} --family-suffix RealMono \
          ${pkgs.noto-fonts-cjk-sans}/share/fonts/opentype/noto-cjk/NotoSansMonoCJK-VF.otf.ttc \
          $out/share/fonts/opentype/NotoSansMonoCJKRealMono-VF.otf.ttc
        python ${./fonts/patch_fixed_pitch.py} --family-suffix RealMono \
          ${pkgs.jigmo}/share/fonts/truetype/Jigmo.ttf \
          $out/share/fonts/truetype/JigmoRealMono.ttf
        python ${./fonts/patch_fixed_pitch.py} --family-suffix RealMono \
          ${pkgs.jigmo}/share/fonts/truetype/Jigmo2.ttf \
          $out/share/fonts/truetype/Jigmo2RealMono.ttf
        python ${./fonts/patch_fixed_pitch.py} --family-suffix RealMono \
          ${pkgs.jigmo}/share/fonts/truetype/Jigmo3.ttf \
          $out/share/fonts/truetype/Jigmo3RealMono.ttf
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

    # The Nerd Font (Symbols only).
    # It is used in Emacs because Emacs allows me to specify which font to use for
    # a particular Unicode code point range.
    # It is also used in Ghostty because Ghostty has `font-codepoint-map`.
    nerd-fonts.symbols-only

    # JuliaMono contains a lot of glyphs for symbols.
    julia-mono
    # This font has monospace and mahjong tiles coverage.
    # https://github.com/lxgw/lxgwwenkaitc
    lxgw-wenkai-tc
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
