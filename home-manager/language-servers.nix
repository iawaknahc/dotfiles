{ pkgs, ... }:
{
  home.packages = with pkgs; [
    awk-language-server
    bash-language-server
    dockerfile-language-server-nodejs
    docker-compose-language-service
    fish-lsp
    gopls
    graphql-language-service-cli
    marksman

    # nil is the language server for Nix.
    # See https://github.com/oxalica/nil
    nil

    nixd
    pyright
    sqls
    tailwindcss-language-server
    taplo
    typescript-language-server
    vscode-langservers-extracted
    yaml-language-server
  ];
}
