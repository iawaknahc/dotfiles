{
  symlinkJoin,
  stdenvNoCC,
  fetchurl,
  lib,
}:
symlinkJoin rec {
  pname = "UTS58-linkification";
  version = "18.0.0";

  _ = lib.asserts.assertMsg (
    lib.strings.compareVersions version "17.0.0" >= 0
  ) "UTS58 is defined since Unicode 17.0, version older than Unicode 17.0 is undefined";

  LinkBracket_txt = stdenvNoCC.mkDerivation rec {
    inherit version;
    pname = "LinkBracket.txt";
    dontUnpack = true;
    src = fetchurl {
      url = "https://www.unicode.org/Public/${version}/linkification/${pname}";
      hash = "sha256-4GKuMXH7QGMsKPcRZZcUTr8C/NOanWfPCopGpYtSYQM=";
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
      hash = "sha256-nzkkC/jidFU3t7pJC3p43fD9xb2szDomwJilK0tdjv4=";
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
      hash = "sha256-q51OC+pEdkRavDYv8dreEv5YsF5YXWg1rHZDQIY99EY=";
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
      hash = "sha256-/lV0zHdiqm/Yc0TXu+j6y2RLlxGyG6a7DOn6KA1SgBM=";
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
      hash = "sha256-gVFQQC+vEfnCxLaSwIoe1hM7/ShvDenKQcXUagCawKs=";
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
