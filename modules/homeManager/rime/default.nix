{ pkgs, ... }:
let
  rimeUserDirectory = "Library/Rime";
in
{
  home.packages = with pkgs; [
    librime-lua
    rime-cangjie
    rime-cantonese
  ];

  home.file."${rimeUserDirectory}/cangjie5.base.dict.yaml".source =
    "${pkgs.rime-cangjie}/share/rime-cangjie/cangjie5.base.dict.yaml";
  home.file."${rimeUserDirectory}/cangjie5_char.dict.yaml".source =
    "${pkgs.rime-cangjie}/share/rime-cangjie/cangjie5_char.dict.yaml";

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
