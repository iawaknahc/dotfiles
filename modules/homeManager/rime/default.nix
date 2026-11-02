{ pkgs, ... }:
let
  rimeUserDirectory = "Library/Rime";
  predict-db = pkgs.stdenvNoCC.mkDerivation {
    pname = "rime-predict-db-words-hk-word-frequency-list";
    version = pkgs.words-hk-word-frequency-list.version;
    src = pkgs.words-hk-word-frequency-list;
    nativeBuildInputs = [
      pkgs.python3
      pkgs.librime
    ];
    buildPhase = ''
      runHook preBuild
      python3 ${../my-scripts/bin/rime-predict-prepare-words-hk.py} <$src/share/words-hk-word-frequency-list/words-hk-word-frequency-list.csv >./predict.tsv
      rime_build_predict <./predict.tsv
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/rime-predict-db-words-hk-word-frequency-list
      cp ./predict.tsv $out/share/rime-predict-db-words-hk-word-frequency-list/
      cp ./predict.db $out/share/rime-predict-db-words-hk-word-frequency-list/
      runHook postInstall
    '';
  };
in
{
  home.packages = with pkgs; [
    librime-lua-typedef
    busted-typedef
    luassert-typedef
    rime-cangjie
    rime-cantonese
    librime
    words-hk-word-frequency-list
    predict-db
    cangjie5-rime
  ];

  home.file."${rimeUserDirectory}/cangjie5.base.dict.yaml".source =
    "${pkgs.rime-cangjie}/share/rime-cangjie/cangjie5.base.dict.yaml";
  home.file."${rimeUserDirectory}/cangjie5_char.dict.yaml".source =
    "${pkgs.rime-cangjie}/share/rime-cangjie/cangjie5_char.dict.yaml";
  home.file."${rimeUserDirectory}/cangjie5_hk.dict.yaml".source =
    "${pkgs.cangjie5-rime}/share/cangjie5-rime/cangjie5_hk.dict.yaml";

  home.file."${rimeUserDirectory}/essay-cantonese.txt".source =
    "${pkgs.rime-cantonese}/share/rime-cantonese/essay-cantonese.txt";
  home.file."${rimeUserDirectory}/jyut6ping3.chars.dict.yaml".source =
    "${pkgs.rime-cantonese}/share/rime-cantonese/jyut6ping3.chars.dict.yaml";
  home.file."${rimeUserDirectory}/jyut6ping3.words.dict.yaml".source =
    "${pkgs.rime-cantonese}/share/rime-cantonese/jyut6ping3.words.dict.yaml";
  home.file."${rimeUserDirectory}/jyut6ping3.phrase.dict.yaml".source =
    "${pkgs.rime-cantonese}/share/rime-cantonese/jyut6ping3.phrase.dict.yaml";
  home.file."${rimeUserDirectory}/jyut6ping3.lettered.dict.yaml".source =
    "${pkgs.rime-cantonese}/share/rime-cantonese/jyut6ping3.lettered.dict.yaml";
  home.file."${rimeUserDirectory}/jyut6ping3.maps.dict.yaml".source =
    "${pkgs.rime-cantonese}/share/rime-cantonese/jyut6ping3.maps.dict.yaml";
  home.file."${rimeUserDirectory}/jyut6ping3.dict.yaml".source =
    "${pkgs.rime-cantonese}/share/rime-cantonese/jyut6ping3.dict.yaml";

  home.file."${rimeUserDirectory}/predict.db".source =
    "${predict-db}/share/rime-predict-db-words-hk-word-frequency-list/predict.db";

  home.file."${rimeUserDirectory}/default.yaml".source = ./default.yaml;
  home.file."${rimeUserDirectory}/squirrel.custom.yaml".source = ./squirrel.custom.yaml;
  home.file."${rimeUserDirectory}/cangjie5_jyut6ping3.schema.yaml".source =
    ./cangjie5_jyut6ping3.schema.yaml;
  home.file."${rimeUserDirectory}/jyut6ping3.schema.yaml".source = ./jyut6ping3.schema.yaml;

  home.file."${rimeUserDirectory}/rime.lua".source = ./rime.lua;
  home.file."${rimeUserDirectory}/lua" = {
    source = ./lua;
    recursive = true;
  };
}
