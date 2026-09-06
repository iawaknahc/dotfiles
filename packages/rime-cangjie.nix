{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "rime-cangjie";
  version = "0-unstable-2026-06-01";
  src = fetchFromGitHub {
    owner = "rime";
    repo = "rime-cangjie";
    rev = "52d90a1b1312e74042b38c1cbc8142defbc53171";
    hash = "sha256-dOwHk+nykmHCcwXZLgph7ucLmSwK3CUoBLg3zmdrqtY=";
  };
  installPhase = ''
    mkdir -p $out/share/rime-cangjie
    cp $src/*.dict.yaml $src/*.schema.yaml $out/share/rime-cangjie
  '';
}
