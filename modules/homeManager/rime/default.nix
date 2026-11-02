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
  rime-unicode-cjk-extension-filter-lua = pkgs.stdenvNoCC.mkDerivation {
    pname = "rime-unicode-cjk-extension-filter-lua";
    version = pkgs.words-hk-character-frequency-list.version;
    src = pkgs.words-hk-character-frequency-list;
    nativeBuildInputs = [
      pkgs.python3
    ];
    buildPhase = ''
      runHook preBuild
      python3 ${../my-scripts/bin/rime-unicode-cjk-extension-filter-prepare.py} <$src/share/words-hk-character-frequency-list/words-hk-character-frequency-list.csv >./rime_unicode_cjk_extension_filter.lua
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/rime-unicode-cjk-extension-filter-lua
      cp ./rime_unicode_cjk_extension_filter.lua $out/share/rime-unicode-cjk-extension-filter-lua/
      runHook postInstall
    '';
  };
in
{
  home.packages = with pkgs; [
    librime-lua-typedef
    busted-typedef
    luassert-typedef
    rime-cantonese
    librime
    words-hk-word-frequency-list
    words-hk-character-frequency-list
    predict-db
    rime-unicode-cjk-extension-filter-lua
    cangjie5-rime
  ];

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
  home.file."${rimeUserDirectory}/lua/unicode_cjk_extension_filter_data.lua".source =
    "${rime-unicode-cjk-extension-filter-lua}/share/rime-unicode-cjk-extension-filter-lua/rime_unicode_cjk_extension_filter.lua";
}
