{ pkgs, config, ... }:
{
  programs.nushell.enable = true;
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
