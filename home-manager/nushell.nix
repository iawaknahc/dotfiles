{ pkgs, config, ... }:
{
  programs.nushell.enable = true;
  # FIXME: nushell does not support home.sessionVariables.
  # See https://github.com/nix-community/home-manager/issues/4313
  programs.nushell.environmentVariables = config.home.sessionVariables;
  programs.nushell.configFile.source = ../.config/nushell/config.nu;
  # Install official plugins.
  programs.nushell.plugins = [
    pkgs.nushellPlugins.polars
    pkgs.nushellPlugins.formats
    pkgs.nushellPlugins.gstat
    pkgs.nushellPlugins.query
  ];
}
