{
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ucdxml-ucd-nounihan-flat";
  version = "18.0.0";
  src = fetchzip {
    url = "https://www.unicode.org/Public/${version}/ucdxml/ucd.nounihan.flat.zip";
    stripRoot = false;
    hash = "sha256-OIDiWxyRrAL3/g/W1WN63sF0lYjvQGqo04w42ywtQF8=";
  };
  installPhase = ''
    mkdir -p $out/share/unicode/${version}/ucdxml
    cp ucd.nounihan.flat.xml $out/share/unicode/${version}/ucdxml
  '';
}
