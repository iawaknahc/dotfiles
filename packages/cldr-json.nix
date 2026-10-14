{
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "cldr-json";
  version = "48.2.3";
  src = fetchzip {
    url = "https://github.com/unicode-org/cldr-json/releases/download/${version}/cldr-${version}-json-full.zip";
    stripRoot = false;
    hash = "sha256-t9YGO7dKGlXZ0TeaY3VZvYzLsY+0LRvY9VXG8Nd6fAc=";
  };
  installPhase = ''
    mkdir -p $out/share/cldr-json/${version}
    mv cldr-* $out/share/cldr-json/${version}/
  '';
}
