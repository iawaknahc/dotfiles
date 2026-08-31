{ pkgs, ... }:
let
  rimeUserDirectory = "Library/Rime";
  rime-cangjie = "52d90a1b1312e74042b38c1cbc8142defbc53171";
  rime-cantonese = "259f0e48bba840c3a2e0d117539e96937f3d89bc";
in
{
  home.file."${rimeUserDirectory}/cangjie5.base.dict.yaml".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rime/rime-cangjie/${rime-cangjie}/cangjie5.base.dict.yaml";
    hash = "sha256-hpDyrYqv04eAhGiBqpFrV3nm2SR6NRodpCbT8yV6/KQ=";
  };
  home.file."${rimeUserDirectory}/cangjie5_char.dict.yaml".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rime/rime-cangjie/${rime-cangjie}/cangjie5_char.dict.yaml";
    hash = "sha256-4917jrpU+WRHSRSzy4dBsjCK5GTP/59/qK4khqNqAbg=";
  };
  home.file."${rimeUserDirectory}/essay-cantonese.txt".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rime/rime-cantonese/${rime-cantonese}/essay-cantonese.txt";
    hash = "sha256-0Ig2F19Zghn0PC8vnhLhJxEhLb7+CNV7Lt23qdnyKl0=";
  };
  home.file."${rimeUserDirectory}/jyut6ping3.chars.dict.yaml".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rime/rime-cantonese/${rime-cantonese}/jyut6ping3.chars.dict.yaml";
    hash = "sha256-mwU6WUyA6udlRbzdgyOYhKSbG6SLicoKuejarHnzMBM=";
  };
  home.file."${rimeUserDirectory}/jyut6ping3.words.dict.yaml".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rime/rime-cantonese/${rime-cantonese}/jyut6ping3.words.dict.yaml";
    hash = "sha256-VNF0rSu5l+SmeLewdrhOTcWRRIGzJGfN6jtD6It9VHQ=";
  };
  home.file."${rimeUserDirectory}/jyut6ping3.phrase.dict.yaml".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rime/rime-cantonese/${rime-cantonese}/jyut6ping3.phrase.dict.yaml";
    hash = "sha256-MHHRykPWhhrvyqFOG3J4CyFTe05YuG/84nrgV3yU4u0=";
  };
  home.file."${rimeUserDirectory}/jyut6ping3.lettered.dict.yaml".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rime/rime-cantonese/${rime-cantonese}/jyut6ping3.lettered.dict.yaml";
    hash = "sha256-Ybojuw5fat2fn0ovjvpTnDUdxPCGoxNCg8+DaIBA2Dk=";
  };
  home.file."${rimeUserDirectory}/jyut6ping3.maps.dict.yaml".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rime/rime-cantonese/${rime-cantonese}/jyut6ping3.maps.dict.yaml";
    hash = "sha256-oocWx3HWrazLtZkmipLdrOCFu9bt6hjmHyr2OxouXIc=";
  };
  home.file."${rimeUserDirectory}/jyut6ping3.dict.yaml".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rime/rime-cantonese/${rime-cantonese}/jyut6ping3.dict.yaml";
    hash = "sha256-z8jNqBdSBr2tpfyfx/T7SS5Zt7mjU2qbbAmaP47gO74=";
  };

  home.file."${rimeUserDirectory}/default.custom.yaml".source = ./default.custom.yaml;
  home.file."${rimeUserDirectory}/squirrel.custom.yaml".source = ./squirrel.custom.yaml;
  home.file."${rimeUserDirectory}/cangjie5_jyut6ping3.schema.yaml".source =
    ./cangjie5_jyut6ping3.schema.yaml;
  home.file."${rimeUserDirectory}/jyut6ping3.schema.yaml".source = ./jyut6ping3.schema.yaml;
}
