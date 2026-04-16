{ pkgs, ... }:
let
  unicode_version = "17.0.0";
  cldr_version = "48.2";

  ucdxml-nounihan = (
    pkgs.stdenvNoCC.mkDerivation rec {
      pname = "ucdxml-nounihan";
      version = unicode_version;
      src = pkgs.fetchzip {
        url = "https://www.unicode.org/Public/${version}/ucdxml/ucd.nounihan.flat.zip";
        stripRoot = false;
        hash = "sha256-9rHBJYX9ZcfAunc9couv25Rs1GzGUBmNPpII4SRStEE=";
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
      version = cldr_version;
      src = pkgs.fetchzip {
        url = "https://unicode.org/Public/cldr/${version}/cldr-common-${version}.zip";
        stripRoot = false;
        hash = "sha256-fFSLvhND8lg9gQFsrP3XScpSsGwCWWjuLhN22gQSVNs=";
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
        "${
          assert pkgs.unicode-character-database.version == unicode_version;
          pkgs.unicode-character-database
        }"
        "${
          assert pkgs.unicode-idna.version == unicode_version;
          pkgs.unicode-idna
        }"
        "${
          assert pkgs.unicode-emoji.version == unicode_version;
          pkgs.unicode-emoji
        }"
        "${ucdxml-nounihan}"
        "${cldr-common}"
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
    ucd

    (bundlerApp {
      pname = "uniscribe";
      # Only Gemfile was hand-written.
      # Gemfile.lock and gemset.nix were generated with `bundix -l`.
      gemdir = ./uniscribe;

      exes = [
        "uniscribe"
      ];
    })
    (bundlerApp {
      pname = "unibits";
      # Only Gemfile was hand-written.
      # Gemfile.lock and gemset.nix were generated with `bundix -l`.
      gemdir = ./unibits;

      exes = [
        "unibits"
      ];
    })
    (bundlerApp {
      pname = "unicopy";
      # Only Gemfile was hand-written.
      # Gemfile.lock and gemset.nix were generated with `bundix -l`.
      gemdir = ./unicopy;

      exes = [
        "unicopy"
      ];
    })

    unicode-paracode

    (stdenvNoCC.mkDerivation {
      name = "unicode.sqlite3";
      nativeBuildInputs = [
        ucd
        python3
      ];
      src = ./.;

      ucd = "${ucd}";

      installPhase = ''
        mkdir -p $out/share/unicode
        python3 ./build_sqlite.py "$ucd"/share/unicode/ucd.nounihan.flat.xml "$ucd"/share/unicode "$ucd"/share/unicode/cldr $out/share/unicode/unicode.sqlite3
      '';
    })
  ];
  home.file.".unicode" = {
    source = "${ucd}/share/unicode";
    recursive = true;
  };
}
