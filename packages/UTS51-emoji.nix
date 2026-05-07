{
  symlinkJoin,
  stdenvNoCC,
  fetchurl,
  lib,
}:
symlinkJoin rec {
  pname = "UTS51-emoji";
  version = "17.0.0";

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
      hash = "sha256-EsyCZ9wzy9Ee0yvPb8XcKtnHp3uuG9+6L0GxubPq2N0=";
    };
    installPhase = ''
      mkdir -p $out/share/unicode/${version}/emoji
      cp $src $out/share/unicode/${version}/emoji/${pname}
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
      hash = "sha256-HYqUT4jXlS9+98UWf+88Z5lbyuJFQ5SXECMbA6IBrNo=";
    };
    installPhase = ''
      mkdir -p $out/share/unicode/${version}/emoji
      cp $src $out/share/unicode/${version}/emoji/${pname}
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
      hash = "sha256-WyVEHa7SMisGjF5wzaUilGpPAnTfhkRFoZZakuX8XK0=";
    };
    installPhase = ''
      mkdir -p $out/share/unicode/${version}/emoji
      cp $src $out/share/unicode/${version}/emoji/${pname}
    '';
  };

  paths = [
    emoji-sequences_txt
    emoji-test_txt
    emoji-zwj-sequences_txt
  ];
}
