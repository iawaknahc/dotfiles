{ pkgs, ... }:
let
  unicode_version = "16.0.0";
  cldr_version = "47";
  cldr_json_version = "47.0.0";

  ucdxml-nounihan = (
    pkgs.stdenvNoCC.mkDerivation rec {
      pname = "ucdxml-nounihan";
      version = unicode_version;
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
      version = cldr_version;
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
  cldr-json = (
    pkgs.stdenvNoCC.mkDerivation rec {
      pname = "cldr-json";
      version = cldr_json_version;
      src = pkgs.fetchzip {
        url = "https://github.com/unicode-org/cldr-json/releases/download/${version}/cldr-${version}-json-full.zip";
        stripRoot = false;
        hash = "sha256-+xELEHy3hq2botBV6buouPuKMk8qWnokTsnV2h57jbQ=";
      };
      installPhase = ''
        mkdir -p $out/share/unicode/cldr-json
        mv cldr-* $out/share/unicode/cldr-json/
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
    cldr-common
    cldr-json
    ucdxml-nounihan
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

    # This program is known to be broken on nixpkgs
    # See https://github.com/NixOS/nixpkgs/pull/420887
    (pkgs.python3Packages.buildPythonApplication {
      pname = "unicode";
      version = "3.2";

      pyproject = true;
      build-system = [ pkgs.python3Packages.setuptools ];

      src = pkgs.fetchFromGitHub {
        owner = "garabik";
        repo = "unicode";
        rev = "fa4fa6118d68c693ee14b97df6bf12d2fdbb37df";
        sha256 = "sha256-wgPJKzblwntRRD2062TPEth28KDycVqWheMTz0v5BVE=";
      };
    })

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
  ];
  home.file.".unicode" = {
    source = "${ucd}/share/unicode";
    recursive = true;
  };
}
