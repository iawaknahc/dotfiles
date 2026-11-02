{
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation {
  pname = "words-hk-character-frequency-list";
  # Version is determined in justfile.
  # Do not edit manually.
  # When this package fails to build due to hash mismatch, do the following
  # 1. Visit https://words.hk/faiman/analysis/charcount/
  # 2. Note the last update date.
  # 3. Update the date in justfile
  # 4. Re-run the justfile recipe to update this package.
  version = "2026-03-30";
  src = fetchurl {
    # Homepage: https://words.hk/faiman/analysis/charcount/
    # License: Public Domain
    url = "https://words.hk/faiman/analysis/charcount.csv";
    hash = "sha256-BJdEK+lDyQwJ3tUXAc/YVb59GBM8mZS5zJwT3o5bmac=";
  };
  dontUnpack = true;
  # The first line is "Source,https://words.hk/faiman/analysis/charcount/", which is not an entry.
  buildPhase = ''
    runHook preBuild
    tail -n +2 <$src >./words-hk-character-frequency-list.csv
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/words-hk-character-frequency-list
    cp ./words-hk-character-frequency-list.csv $out/share/words-hk-character-frequency-list/
    runHook postInstall
  '';
}
