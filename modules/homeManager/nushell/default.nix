{
  pkgs,
  config,
  ...
}:
{
  home.packages = with pkgs; [
    nufmt
  ];
  programs.nushell.enable = true;
  # FIXME: nushell does not support home.sessionVariables.
  # See https://github.com/nix-community/home-manager/issues/4313
  programs.nushell.environmentVariables = config.home.sessionVariables;
  programs.nushell.configFile.source = ./config/nushell/config.nu;
  programs.nushell.plugins = [
    # These are official plugins.
    pkgs.nushellPlugins.polars
    pkgs.nushellPlugins.formats
    pkgs.nushellPlugins.gstat
    pkgs.nushellPlugins.query

    # Plugins authored by a core maintainer of Nushell.
    pkgs.nu_plugin_dt
    pkgs.nu_plugin_regex
  ];
}
