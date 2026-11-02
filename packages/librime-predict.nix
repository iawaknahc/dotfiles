{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "librime-predict";
  version = "data-1.0-unstable-2024-11-18";

  src = fetchFromGitHub {
    owner = "rime";
    repo = "librime-predict";
    rev = "920bd41ebf6f9bf6855d14fbe80212e54e749791";
    hash = "sha256-Aasu/Ia/MJCUhcqfZsG3AulfhOfYpYM/M9iAqTewaU8=";
  };

  # Patch CMakeLists.txt to install the built executable.
  postPatch = ''
    printf 'install(TARGETS build_predict DESTINATION ''${BIN_INSTALL_DIR})\n' >> ./tools/CMakeLists.txt
  '';

  # This package does not built itself.
  # This package is supposed to be built along with librime.
  # So the only thing to do in install phase is to copy the source files.
  # This handling is taken from the existing packaged librime plugin librime-octagram.
  # See https://github.com/NixOS/nixpkgs/blob/nixos-26.05/pkgs/by-name/li/librime-octagram/package.nix#L19
  installPhase = ''
    runHook preInstall
    mkdir $out
    cp --archive --verbose * $out
    runHook postInstall
  '';
}
