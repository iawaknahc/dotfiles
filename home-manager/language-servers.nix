{ pkgs, ... }:
{
  imports = [ ./tailwindcss-language-server.nix ];

  config = {
    home.packages = [
      pkgs.awk-language-server
      pkgs.bash-language-server
      pkgs.fish-lsp
      pkgs.gopls
      pkgs.lua-language-server
      # nil the the language server for Nix.
      # See https://github.com/oxalica/nil
      pkgs.nil
      pkgs.nixd
      pkgs.nodePackages.graphql-language-service-cli
      pkgs.pyright
      pkgs.sqls
      pkgs.taplo
      pkgs.typescript-language-server
      pkgs.typos-lsp
      pkgs.vscode-langservers-extracted
      pkgs.yaml-language-server
    ];
  };
}
