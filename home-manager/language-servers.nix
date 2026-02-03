{ pkgs, ... }:
{
  home.packages = with pkgs; [
    awk-language-server # .awk
    bash-language-server # .sh
    docker-compose-language-service # docker-compose.yaml
    dockerfile-language-server # Dockerfile
    fish-lsp # .fish
    gopls # .go
    graphql-language-service-cli # .graphql
    jdt-language-server # .java

    # marksman is written in F# and it is not prebuilt on nixpkgs as of 2026-02-03.
    # It takes an unpractical time to build the whole dotnet package.
    # marksman # .md

    markdown-oxide

    nil # .nix
    nixd # .nix
    sqls # .sql
    tailwindcss-language-server # .css
    taplo # .toml
    typescript-language-server # .ts .tsx
    vscode-langservers-extracted # .html .css
    vtsls # .ts .tsx
    yaml-language-server # .yaml
  ];
}
