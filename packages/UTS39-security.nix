{
  stdenvNoCC,
  fetchzip,
  lib,
}:
stdenvNoCC.mkDerivation rec {
  pname = "UTS39-security";
  version = "18.0.0";
  src = fetchzip {
    url =
      # Since Unicode 17.0.0, the location of the data files has changed.
      # See https://www.unicode.org/reports/tr39/#Data_Files
      if lib.strings.compareVersions version "17.0.0" >= 0 then
        "https://www.unicode.org/Public/${version}/security/uts39-data-${version}.zip"
      else
        "https://www.unicode.org/Public/security/${version}/uts39-data-${version}.zip";
    hash = "sha256-IW/QO6p1a0UwP2SEajWNWmoCGMgLqX0gQU+qpv/49MU=";
    stripRoot = false;
  };
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/unicode/${version}/security
    cp --recursive --no-target-directory ./. $out/share/unicode/${version}/security/
    runHook postInstall
  '';
}
