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
    runHook preInstall
    install -Dm644 -t $out/share/rime-cangjie/ \
      ./*.dict.yaml \
      ./*.schema.yaml
    runHook postInstall
  '';
}
