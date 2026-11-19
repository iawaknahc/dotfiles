{
  symlinkJoin,
  stdenvNoCC,
  fetchurl,
  lib,
}:
symlinkJoin rec {
  pname = "UTS51-emoji";
  version = "18.0.0";

  emoji-sequences_txt = stdenvNoCC.mkDerivation rec {
    inherit version;
    pname = "emoji-sequences.txt";
    dontUnpack = true;
    src = fetchurl {
      url =
        # The URL to this data file has changed since Unicode 17.0
        # See https://www.unicode.org/reports/tr51/#emoji_data
        if lib.strings.compareVersions version "17.0.0" >= 0 then
          "https://www.unicode.org/Public/${version}/emoji/${pname}"
        else
          "https://www.unicode.org/Public/emoji/${version}/${pname}";
      hash = "sha256-GCPc5x892csK0Zdnl7ruT/vcGQl1b0OvjOTFf3MoQ6Q=";
    };
    installPhase = ''
      runHook preInstall
      install -Dm644 $src $out/share/unicode/${version}/emoji/${pname}
      runHook postInstall
    '';
  };

  emoji-test_txt = stdenvNoCC.mkDerivation rec {
    inherit version;
    pname = "emoji-test.txt";
    dontUnpack = true;
    src = fetchurl {
      url =
        # The URL to this data file has changed since Unicode 17.0
        # See https://www.unicode.org/reports/tr51/#emoji_data
        if lib.strings.compareVersions version "17.0.0" >= 0 then
          "https://www.unicode.org/Public/${version}/emoji/${pname}"
        else
          "https://www.unicode.org/Public/emoji/${version}/${pname}";
      hash = "sha256-jzc1zaH5KnedeK9nz4YGa7HwcUPcIvKsKTlNm8V6sho=";
    };
    installPhase = ''
      runHook preInstall
      install -Dm644 $src $out/share/unicode/${version}/emoji/${pname}
      runHook postInstall
    '';
  };

  emoji-zwj-sequences_txt = stdenvNoCC.mkDerivation rec {
    inherit version;
    pname = "emoji-zwj-sequences.txt";
    dontUnpack = true;
    src = fetchurl {
      url =
        # The URL to this data file has changed since Unicode 17.0
        # See https://www.unicode.org/reports/tr51/#emoji_data
        if lib.strings.compareVersions version "17.0.0" >= 0 then
          "https://www.unicode.org/Public/${version}/emoji/${pname}"
        else
          "https://www.unicode.org/Public/emoji/${version}/${pname}";
      hash = "sha256-9htSE734Wld0Gp+QPLONDzmj0Tvm/0rKOzmFfoWakZE=";
    };
    installPhase = ''
      runHook preInstall
      install -Dm644 $src $out/share/unicode/${version}/emoji/${pname}
      runHook postInstall
    '';
  };

  paths = [
    emoji-sequences_txt
    emoji-test_txt
    emoji-zwj-sequences_txt
  ];
}
