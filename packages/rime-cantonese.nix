{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "rime-cantonese";
  version = "latest-unstable-2026-08-13";
  src = fetchFromGitHub {
    owner = "rime";
    repo = "rime-cantonese";
    rev = "259f0e48bba840c3a2e0d117539e96937f3d89bc";
    hash = "sha256-ctyYZQVCd9Sc7oqPmP4lO1Q0TYDQILqt/BRloaEWjPg=";
  };
  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out/share/rime-cantonese/ \
      ./*.dict.yaml \
      ./*.schema.yaml \
      ./essay-cantonese.txt
    runHook postInstall
  '';
}
