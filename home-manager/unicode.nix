{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (stdenvNoCC.mkDerivation rec {
      pname = "cldr-json";
      version = "47.0.0";
      src = fetchzip {
        url = "https://github.com/unicode-org/cldr-json/releases/download/${version}/cldr-${version}-json-full.zip";
        stripRoot = false;
        hash = "sha256-+xELEHy3hq2botBV6buouPuKMk8qWnokTsnV2h57jbQ=";
      };
      installPhase = ''
        mkdir -p $out/share/cldr-json
        mv cldr-* $out/share/cldr-json/
      '';
    })

    (stdenvNoCC.mkDerivation rec {
      pname = "ucdxml-nounihan";
      version = "16.0.0";
      src = fetchzip {
        url = "https://www.unicode.org/Public/${version}/ucdxml/ucd.nounihan.flat.zip";
        stripRoot = false;
        hash = "sha256-Gg3YGaFFeoAu4YTUr8oJpxOvm13N3aKG+Vzf56Htxe0=";
      };
      installPhase = ''
        mkdir -p $out/share/unicode
        mv ucd.nounihan.flat.xml $out/share/unicode/
      '';
    })

    # https://www.unicode.org/Public/UCD/
    unicode-character-database
    # https://www.unicode.org/Public/idna/
    unicode-idna
    # https://www.unicode.org/Public/emoji/
    unicode-emoji

    # This program is known to be broken on nixpkgs
    # See https://github.com/NixOS/nixpkgs/pull/420887
    unicode-paracode
  ];
  home.file.".unicode" = {
    source = "${pkgs.unicode-character-database}/share/unicode";
    recursive = true;
  };
}
