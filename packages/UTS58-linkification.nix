{
  symlinkJoin,
  stdenvNoCC,
  fetchurl,
  lib,
}:
symlinkJoin rec {
  pname = "UTS58-linkification";
  version = "17.0.0";

  _ = lib.asserts.assertMsg (
    lib.strings.compareVersions version "17.0.0" >= 0
  ) "UTS58 is defined since Unicode 17.0, version older than Unicode 17.0 is undefined";

  LinkBracket_txt = stdenvNoCC.mkDerivation rec {
    inherit version;
    pname = "LinkBracket.txt";
    dontUnpack = true;
    src = fetchurl {
      url = "https://www.unicode.org/Public/${version}/linkification/${pname}";
      hash = "sha256-0JXYFWrVzklSf9aiDbtR3wXHWFyggePHRYCdTMqp1bw=";
    };
    installPhase = ''
      mkdir -p $out/share/unicode/${version}/linkification
      cp $src $out/share/unicode/${version}/linkification/${pname}
    '';
  };

  LinkDetectionTest_txt = stdenvNoCC.mkDerivation rec {
    inherit version;
    pname = "LinkDetectionTest.txt";
    dontUnpack = true;
    src = fetchurl {
      url = "https://www.unicode.org/Public/${version}/linkification/${pname}";
      hash = "sha256-tX6n4pe1/EuObpMyKleNiiWsRMv68Pkx1a1oK+SIfds=";
    };
    installPhase = ''
      mkdir -p $out/share/unicode/${version}/linkification
      cp $src $out/share/unicode/${version}/linkification/${pname}
    '';
  };

  LinkEmail_txt = stdenvNoCC.mkDerivation rec {
    inherit version;
    pname = "LinkEmail.txt";
    dontUnpack = true;
    src = fetchurl {
      url = "https://www.unicode.org/Public/${version}/linkification/${pname}";
      hash = "sha256-urLYR2+3P6Yolac+3T2HxeSelmQDXM9NhBoXpEux67k=";
    };
    installPhase = ''
      mkdir -p $out/share/unicode/${version}/linkification
      cp $src $out/share/unicode/${version}/linkification/${pname}
    '';
  };

  LinkFormattingTest_txt = stdenvNoCC.mkDerivation rec {
    inherit version;
    pname = "LinkFormattingTest.txt";
    dontUnpack = true;
    src = fetchurl {
      url = "https://www.unicode.org/Public/${version}/linkification/${pname}";
      hash = "sha256-yQ44gtjc7avAthW2XhteRDAshmLFE2yyW6KLPLQIHdE=";
    };
    installPhase = ''
      mkdir -p $out/share/unicode/${version}/linkification
      cp $src $out/share/unicode/${version}/linkification/${pname}
    '';
  };

  LinkTerm_txt = stdenvNoCC.mkDerivation rec {
    inherit version;
    pname = "LinkTerm.txt";
    dontUnpack = true;
    src = fetchurl {
      url = "https://www.unicode.org/Public/${version}/linkification/${pname}";
      hash = "sha256-tcO3gJknjPbC3MnjcwxmOLYPRGTzXFiU4IM5kC57ETg=";
    };
    installPhase = ''
      mkdir -p $out/share/unicode/${version}/linkification
      cp $src $out/share/unicode/${version}/linkification/${pname}
    '';
  };

  paths = [
    LinkBracket_txt
    LinkDetectionTest_txt
    LinkEmail_txt
    LinkFormattingTest_txt
    LinkTerm_txt
  ];
}
