{ pkgs, ... }:
let
  ucdxml-nounihan = (
    pkgs.stdenvNoCC.mkDerivation rec {
      pname = "ucdxml-nounihan";
      version = "16.0.0";
      src = pkgs.fetchzip {
        url = "https://www.unicode.org/Public/${version}/ucdxml/ucd.nounihan.flat.zip";
        stripRoot = false;
        hash = "sha256-Gg3YGaFFeoAu4YTUr8oJpxOvm13N3aKG+Vzf56Htxe0=";
      };
      installPhase = ''
        mkdir -p $out/share/unicode
        mv ucd.nounihan.flat.xml $out/share/unicode/
      '';
    }
  );
  cldr-common = (
    pkgs.stdenvNoCC.mkDerivation rec {
      pname = "cldr-common";
      version = "47";
      src = pkgs.fetchzip {
        url = "https://unicode.org/Public/cldr/${version}/cldr-common-${version}.zip";
        stripRoot = false;
        hash = "sha256-ZMXdLuFXDqu/c9sYug6bWkuQWcS3eQ+EUDKtOP5Htu8=";
      };
      installPhase = ''
        mkdir -p $out/share/unicode/cldr
        mv common $out/share/unicode/cldr/
      '';
    }
  );
  ucd = (
    pkgs.stdenvNoCC.mkDerivation {
      name = "ucd";

      # We need to set sourceRoot because we now have multiple directories.
      sourceRoot = ".";
      srcs = [
        "${pkgs.unicode-character-database}"
        "${pkgs.unicode-idna}"
        "${pkgs.unicode-emoji}"
      ];

      installPhase = ''
        mkdir -p $out/share/unicode
        cp -R */share/unicode/. $out/share/unicode/
      '';
    }
  );
in
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
        mkdir -p $out/share/unicode/cldr-json
        mv cldr-* $out/share/unicode/cldr-json/
      '';
    })

    cldr-common
    ucdxml-nounihan
    ucd

    (stdenvNoCC.mkDerivation {
      name = "unicode.sqlite3";
      nativeBuildInputs = [
        cldr-common
        ucdxml-nounihan
        python3
      ];
      src = ./.;

      ucdxml_nounihan = "${ucdxml-nounihan}";
      ucd = "${ucd}";
      cldr_common = "${cldr-common}";

      installPhase = ''
        mkdir -p $out/share/unicode
        python3 ./build_sqlite.py "$ucdxml_nounihan"/share/unicode/ucd.nounihan.flat.xml "$ucd"/share/unicode "$cldr_common"/share/unicode/cldr $out/share/unicode/unicode.sqlite3
      '';
    })

    # This program is known to be broken on nixpkgs
    # See https://github.com/NixOS/nixpkgs/pull/420887
    unicode-paracode
  ];
  home.file.".unicode" = {
    source = "${ucd}/share/unicode";
    recursive = true;
  };
}
