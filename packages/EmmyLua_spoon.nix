{
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "EmmyLua_spoon";
  version = "0-unstable-2026-03-13";
  src = fetchFromGitHub {
    owner = "Hammerspoon";
    repo = "Spoons";
    rev = "5c20bcecc380acff5f0f5df7a718c5679aaaf62a";
    hash = "sha256-LeMsmm/au7GbnETVAUNNABanjU1byXpYbzWG/5nT4sM=";
  };
  installPhase = ''
    mkdir -p $out/share/Spoons
    cp -R $src/Source/EmmyLua.spoon/. $out/share/Spoons/EmmyLua.spoon
  '';
}
