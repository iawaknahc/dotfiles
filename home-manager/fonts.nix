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
    #
    # However, even though it is not recognized by macOS,
    # it is actually possible to ask Ghostty to use it.
    # It is just that `ghostty +list-fonts` does not report Source Han Mono is a candidate.
    #
    # In JetBrainsMono, the light style is called "Light".
    # In Source Han Mono, the light style is called "L".
    # The font-style-* options in Ghostty cannot be specified per font.
    # Therefore, when we specify multiple --font-family,
    # we have to make sure all font family shares the same set of style.
    #
    # So in here, we patch Source Han Mono such that its "L" is renamed to "Light".
    # And then we can configure Ghostty as follows:
    #
    # --font-family=""
    # --font-family="JetBrainsMonoNL Nerd Font Mono"
    # --font-family="Source Han Mono"
    # --font-style="Light"
    # --font-style-bold="Bold"
    # --font-style-italic="Light Italic"
    # --font-style-bold-italic="Bold Italic"
    (source-han-mono.overrideAttrs (prev: {
      myFixScript = ''
        import re
        import sys

        from fontTools.ttLib import TTCollection

        L = re.compile(r"\bL\b")

        fonts = []
        for font in TTCollection("./SourceHanMono.ttc").fonts:
            is_L = False
            name_table = font["name"]
            for record in name_table.names:
                if record.nameID == 17 and L.match(record.toUnicode()) is not None:
                    is_L = True
            if is_L:
                for record in name_table.names:
                    if record.nameID in [1, 2, 4, 6, 16, 17]:
                        old_name = record.toUnicode()
                        new_name = L.sub("Light", old_name)
                        record.string = new_name
                        print(
                            f"Change {record.nameID}: {old_name} to {new_name}", file=sys.stderr
                        )
            fonts.append(font)

        new_ttc = TTCollection()
        new_ttc.fonts = fonts
        new_ttc.save("./SourceHanMono.ttc")
      '';

      postPatch = ''
        # For some unknown reason, this file is 0o444
        # Let's make it writable first.
        chmod u+w ./SourceHanMono.ttc
        md5sum ./SourceHanMono.ttc
        ${pkgs.mypython}/bin/python -c "$myFixScript"
        md5sum ./SourceHanMono.ttc
        # Make it read-only again.
        chmod u-w ./SourceHanMono.ttc
      '';
    }))

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
