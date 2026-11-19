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
    runHook preInstall
    mkdir $out
    cp --recursive --no-target-directory ./Workflow/. $out/
    runHook postInstall
  '';
}
