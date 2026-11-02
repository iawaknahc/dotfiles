{
  fetchurl,
  libarchive,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "cangjie5-rime";
  version = "4.1-beta";

  # Ideally, we should use fetchzip.
  # But it does not work with zip archive containing directories with Chinese characters.
  src = fetchurl {
    url = "https://github.com/Jackchows/Cangjie5/releases/download/v4.1-beta/RimeData_Cangjie5_20260207.zip";
    hash = "sha256-4v0MbCW0RVvBtbC1wSc5msLDMrJe4FfUiR8U+wLBlAg=";
  };

  nativeBuildInputs = [ libarchive ];

  unpackCmd = ''
    export LC_ALL=C.UTF-8
    mkdir source
    bsdtar -xf "$curSrc" -C source
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/cangjie5-rime
    find . -name '*.yaml' -exec cp {} $out/share/cangjie5-rime/ \;
    runHook postInstall
  '';
}
