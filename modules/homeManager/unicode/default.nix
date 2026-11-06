{ pkgs, ... }:
{
  home.packages = with pkgs; [
    UTS39-security
    UAX44-ucd
    UTS46-idna
    UTS51-emoji
    UTS58-linkification
    ucdxml-ucd-nounihan-flat
    cldr-json
  ];
}
