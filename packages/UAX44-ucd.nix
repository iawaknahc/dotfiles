{
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "UAX44-ucd";
  version = "17.0.0";
  src = fetchzip {
    url = "https://www.unicode.org/Public/${version}/ucd/UCD.zip";
    hash = "sha256-k2OFy8xPvn+Bboyr1EsmZNeVDOglvk2kSZ+H17YaX60=";
    stripRoot = false;
  };
  installPhase = ''
    mkdir -p $out/share/unicode/${version}/ucd
    cp -R $src/. $out/share/unicode/${version}/ucd/
  '';
}
