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

    unicode-character-database
    # This program is known to be broken on nixpkgs
    # See https://github.com/NixOS/nixpkgs/pull/420887
    unicode-paracode
  ];
  home.file.".unicode" = {
    source = "${pkgs.unicode-character-database}/share/unicode";
    recursive = true;
  };
}
