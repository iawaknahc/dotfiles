{ pkgs, ... }:
{
  home.packages = with pkgs; [
    awk-language-server
    bash-language-server
    fish-lsp
    gopls

    # graphql-language-service-cli is installed with npx

    marksman
    # nil the the language server for Nix.
    # See https://github.com/oxalica/nil
    nil
    nixd
    pyright
    sqls
    tailwindcss-language-server
    taplo
    typescript-language-server
    typos-lsp
    vscode-langservers-extracted
    yaml-language-server
  ];
}
