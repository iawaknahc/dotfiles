{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "librime-lua";
  version = "lua-dev-build-17-unstable-2026-10-10";
  src = fetchFromGitHub {
    owner = "hchunhui";
    repo = "librime-lua";
    rev = "6da5d6cedb853380ed1b5b9b6979cb1a9c028353";
    hash = "sha256-zEgTdBf8Qjd++kaWkPY+2FEOgPYufspNQPFG52QZkUo=";
  };
  installPhase = ''
    mkdir -p $out/share/librime-lua
    cp $src/contrib/librime.lua $out/share/librime-lua/librime.lua
  '';
}
