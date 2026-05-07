{
  symlinkJoin,
  stdenvNoCC,
  fetchurl,
  lib,
}:
symlinkJoin rec {
  pname = "UTS46-idna";
  version = "17.0.0";

  Idna2008_txt = stdenvNoCC.mkDerivation rec {
    inherit version;
    pname = "Idna2008.txt";
    dontUnpack = true;
    src = fetchurl {
      # The URL to this data file has changed since Unicode 17.0
      # See https://www.unicode.org/reports/tr46/#IDNA_Derived_Property
      url =
        if lib.strings.compareVersions version "17.0.0" >= 0 then
          "https://www.unicode.org/Public/${version}/idna/${pname}"
        else
          "https://www.unicode.org/Public/idna/idna2008derived/Idna2008-${version}.txt";
      hash = "sha256-5KdSaoo3U5wN76TaJfXb930CEqFNR2LUVcrepgiokhw=";
    };
    installPhase = ''
      mkdir -p $out/share/unicode/${version}/idna
      cp $src $out/share/unicode/${version}/idna/${pname}
    '';
  };

  IdnaMappingTable_txt = stdenvNoCC.mkDerivation rec {
    inherit version;
    pname = "IdnaMappingTable.txt";
    dontUnpack = true;
    src = fetchurl {
      url =
        # The URL to this data file has changed since Unicode 17.0
        # See https://www.unicode.org/reports/tr46/#IDNATable
        if lib.strings.compareVersions version "17.0.0" >= 0 then
          "https://www.unicode.org/Public/${version}/idna/${pname}"
        else
          "https://www.unicode.org/Public/idna/${version}/${pname}";
      hash = "sha256-h/BVBdwCb9sr/xYTK9xoqAFGdYNogqmisYRFQK0744I=";
    };
    installPhase = ''
      mkdir -p $out/share/unicode/${version}/idna
      cp $src $out/share/unicode/${version}/idna/${pname}
    '';
  };

  IdnaTestV2_txt = stdenvNoCC.mkDerivation rec {
    inherit version;
    pname = "IdnaTestV2.txt";
    dontUnpack = true;
    src = fetchurl {
      url =
        # The URL to this data file has changed since Unicode 17.0
        # See https://www.unicode.org/reports/tr46/#IDNATable
        if lib.strings.compareVersions version "17.0.0" >= 0 then
          "https://www.unicode.org/Public/${version}/idna/${pname}"
        else
          "https://www.unicode.org/Public/idna/${version}/${pname}";
      hash = "sha256-vrXQviDolhibAyCagv3DTwY1FQK71LjiUjWD/ClU2c8=";
    };
    installPhase = ''
      mkdir -p $out/share/unicode/${version}/idna
      cp $src $out/share/unicode/${version}/idna/${pname}
    '';
  };

  paths = [
    Idna2008_txt
    IdnaMappingTable_txt
    IdnaTestV2_txt
  ];
}
