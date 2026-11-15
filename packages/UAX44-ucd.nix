{
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "UAX44-ucd";
  version = "18.0.0";
  src = fetchzip {
    url = "https://www.unicode.org/Public/${version}/ucd/UCD.zip";
    hash = "sha256-xD3LVehqP02v8fsF01BmogKljnjQxnfdc6iqLTcu7FQ=";
    stripRoot = false;
  };
  installPhase = ''
    mkdir -p $out/share/unicode/${version}/ucd
    cp -R $src/. $out/share/unicode/${version}/ucd/
  '';
}
