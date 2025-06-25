{ pkgs, ... }:
{
  home.packages = with pkgs; [
    awk-language-server # .awk
    bash-language-server # .sh
    docker-compose-language-service # docker-compose.yaml
    dockerfile-language-server-nodejs # Dockerfile
    fish-lsp # .fish
    gopls # .go
    graphql-language-service-cli # .graphql
    jdt-language-server # .java
    marksman # .md
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
