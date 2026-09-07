{
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ucdxml-ucd-nounihan-flat";
  version = "17.0.0";
  src = fetchzip {
    url = "https://www.unicode.org/Public/${version}/ucdxml/ucd.nounihan.flat.zip";
    stripRoot = false;
    hash = "sha256-9rHBJYX9ZcfAunc9couv25Rs1GzGUBmNPpII4SRStEE=";
  };
  installPhase = ''
    mkdir -p $out/share/unicode/${version}/ucdxml
    cp ucd.nounihan.flat.xml $out/share/unicode/${version}/ucdxml
  '';
}
