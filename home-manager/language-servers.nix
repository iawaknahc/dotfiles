{ pkgs, ... }:
{
  imports = [ ./tailwindcss-language-server.nix ];

  config = {
    home.packages = [
      pkgs.gopls
      pkgs.lua-language-server
      # nil the the language server for Nix.
      # See https://github.com/oxalica/nil
      pkgs.nil
      pkgs.nodePackages.bash-language-server
      pkgs.nodePackages.graphql-language-service-cli
      pkgs.nodePackages.typescript-language-server
      pkgs.pyright
      # Taplo is a language server for TOML, and more.
      # See https://taplo.tamasfe.dev/
      pkgs.taplo
      pkgs.typos-lsp
      pkgs.vscode-langservers-extracted
      pkgs.yaml-language-server
    ];
  };
}
