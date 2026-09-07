{ pkgs, ... }:
{
  home.packages = with pkgs; [
    UTS39-security
    UAX44-ucd
    UTS46-idna
    UTS51-emoji
    UTS58-linkification
    ucdxml-ucd-nounihan-flat

    cldr-common

    (stdenvNoCC.mkDerivation {
      name = "unicode.sqlite3";
      nativeBuildInputs = [
        ucdxml-ucd-nounihan-flat
        UAX44-ucd
        UTS51-emoji
        cldr-common
        python3
      ];
      src = ./.;

      installPhase = ''
        mkdir -p $out/share/unicode
        python3 ./build_sqlite.py \
          ${ucdxml-ucd-nounihan-flat}/share/unicode/${ucdxml-ucd-nounihan-flat.version} \
          ${UAX44-ucd}/share/unicode/${UAX44-ucd.version} \
          ${UTS51-emoji}/share/unicode/${UTS51-emoji.version} \
          ${cldr-common}/share/cldr/${cldr-common.version} \
          $out/share/unicode/unicode.sqlite3
      '';
    })
  ];
}
