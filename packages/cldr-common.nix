{
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "cldr-common";
  version = "48.2";
  src = fetchzip {
    url = "https://unicode.org/Public/cldr/${version}/cldr-common-${version}.zip";
    stripRoot = false;
    hash = "sha256-fFSLvhND8lg9gQFsrP3XScpSsGwCWWjuLhN22gQSVNs=";
  };
  installPhase = ''
    mkdir -p $out/share/cldr/${version}
    mv common $out/share/cldr/${version}
  '';
}
