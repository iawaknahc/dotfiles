{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "librime-lua";
  version = "lua-dev-build-17-unstable-2026-08-31";
  src = fetchFromGitHub {
    owner = "hchunhui";
    repo = "librime-lua";
    rev = "ad1e4a6c98abf634dd34242a747f9b1d5d069fbe";
    hash = "sha256-Zi5VyFyLk4n34+TEDvV2HEYQKL60mEiVVLFKb6hWFdE=";
  };
  installPhase = ''
    mkdir -p $out/share/librime-lua
    cp $src/contrib/librime.lua $out/share/librime-lua/librime.lua
  '';
}
