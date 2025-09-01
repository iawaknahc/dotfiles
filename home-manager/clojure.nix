{ pkgs, ... }:
{
  home.packages = with pkgs; [
    babashka
    clojure
    clojure-lsp
    cljfmt
    boot
    leiningen
  ];

  # https://clojure.org/reference/clojure_cli#config_dir
  home.file.".clojure/deps.edn".text = ''
    {
      :deps {
        com.ibm.icu/icu4j {:mvn/version "77.1"}
      }
    }
  '';
}
