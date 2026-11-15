{
  symlinkJoin,
  stdenvNoCC,
  fetchurl,
  lib,
}:
symlinkJoin rec {
  pname = "UTS46-idna";
  version = "18.0.0";

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
      hash = "sha256-2Zy6myxMtBj2jPouQ0R82/8b/YtkIJq47sg/OxMdKE0=";
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
      hash = "sha256-oDses4AyJoxpZAaoPwly1qgVrNLI1BUdQuwP2nD/ztE=";
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
      hash = "sha256-Aja3XFsg39hXs7XPdVCYh5WdarANbHvam33D31GMH94=";
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
