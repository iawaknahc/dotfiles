{
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation {
  pname = "words-hk-word-frequency-list";
  # Version is determined in justfile.
  # Do not edit manually.
  # When this package fails to build due to hash mismatch, do the following
  # 1. Visit https://words.hk/faiman/analysis/existingwordcount/
  # 2. Note the last update date.
  # 3. Update the date in justfile
  # 4. Re-run the justfile recipe to update this package.
  version = "2026-03-30";
  src = fetchurl {
    # Homepage: https://words.hk/faiman/analysis/existingwordcount/
    # License: Public Domain
    url = "https://words.hk/faiman/analysis/existingwordcount.csv";
    hash = "sha256-M7CNLkyrS9+bSByVbaaL4JeEwmOPmZ2n+I+3DPn8SWA=";
  };
  dontUnpack = true;
  # The first line is "Source,https://words.hk/faiman/analysis/existingwordcount/", which is not an entry.
  buildPhase = ''
    runHook preBuild
    tail -n +2 <$src >./words-hk-word-frequency-list.csv
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/words-hk-word-frequency-list
    cp ./words-hk-word-frequency-list.csv $out/share/words-hk-word-frequency-list/
    runHook postInstall
  '';
}
