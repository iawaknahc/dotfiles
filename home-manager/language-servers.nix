{ pkgs, ... }:
{
  imports = [ ./tailwindcss-language-server.nix ];

  config = {
    home.packages = with pkgs; [
      awk-language-server
      bash-language-server
      fish-lsp
      gopls
      lua-language-server
      # nil the the language server for Nix.
      # See https://github.com/oxalica/nil
      nil
      nixd
      nodePackages.graphql-language-service-cli
      pyright
      sqls
      taplo
      typescript-language-server
      typos-lsp
      vscode-langservers-extracted
      yaml-language-server
    ];
  };
}
