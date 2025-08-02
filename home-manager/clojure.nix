{ pkgs, ... }:
{
  home.packages = with pkgs; [
    clojure
    clojure-lsp
    cljfmt
    boot
    leiningen
  ];
}
