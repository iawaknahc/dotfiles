{
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "alfred-workflow-switch-appearance";
  version = "2024.1";

  src = fetchFromGitHub {
    owner = "alfredapp";
    repo = "switch-appearance-workflow";
    rev = "${version}";
    hash = "sha256-OBoZrJCHnLaZ0cTHGBfh6RPySwcSDLQUlp/2eexzi14=";
  };

  installPhase = ''
    mkdir $out
    cp -R ./Workflow/. $out/
  '';
}
