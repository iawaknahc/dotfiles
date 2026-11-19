{
  fetchFromGitHub,
  jetbrains-mono,
  lib,
  python3,
  stdenvNoCC,
}:
let
  rev = "fdc2d50326e04961416c33dc13cf1fa9a7b381e2";
in
stdenvNoCC.mkDerivation {
  pname = "gl-mahjongtile-clr";
  version = "0-unstable-2023-12-18";

  src = fetchFromGitHub {
    owner = "Gutenberg-Labo";
    repo = "DingbatFonts";
    inherit rev;
    hash = "sha256-+Ml+Rr/6fNFYrvlnWmoDP0QNC3qyd/r3juNXDzbRfak=";
  };

  nativeBuildInputs = [
    (python3.withPackages (ps: [
      ps.fonttools
      # fontTools needs lxml to subset the SVG table.
      ps.lxml
    ]))
  ];

  # Upstream only ships the colored font as a web font (WOFF / WOFF2).
  # The script converts it to OpenType, and patches it to match JetBrains Mono NL.
  # See ./gl-mahjongtile-clr.py for details.
  buildPhase = ''
    runHook preBuild
    python3 -I ${./gl-mahjongtile-clr.py} \
      --reference ${jetbrains-mono}/share/fonts/truetype/JetBrainsMonoNL-Regular.ttf \
      ./fonts/woff/GL-MahjongTile-Clr.woff \
      ./GL-MahjongTile-Clr-FullWidth.otf
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out/share/fonts/opentype/ \
      ./GL-MahjongTile-Clr-FullWidth.otf
    runHook postInstall
  '';

  meta = {
    description = "Colored OpenType-SVG Mahjong tile font by Gutenberg Labo, patched to match JetBrains Mono NL";
    homepage = "https://github.com/Gutenberg-Labo/DingbatFonts";
    license = {
      fullName = "Gutenberg Labo free software license";
      url = "https://github.com/Gutenberg-Labo/DingbatFonts/blob/${rev}/LICENSE.txt";
      free = true;
      redistributable = true;
    };
    platforms = lib.platforms.all;
  };
}
