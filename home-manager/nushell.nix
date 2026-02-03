{ pkgs, config, ... }:
{
  # nushell is broken on macOS, see https://github.com/NixOS/nixpkgs/issues/485915
  # As of 2026-02-03, the fix is on master only https://github.com/NixOS/nixpkgs/pull/486297
  # programs.nushell.enable = true;
  programs.nushell.enable = false;
  programs.nushell.shellAliases = config.home.shellAliases;
  programs.nushell.configFile.source = ../.config/nushell/config.nu;
  # Install official plugins.
  programs.nushell.plugins = [
    pkgs.nushellPlugins.polars
    pkgs.nushellPlugins.formats
    pkgs.nushellPlugins.gstat
    pkgs.nushellPlugins.query
  ];
}
