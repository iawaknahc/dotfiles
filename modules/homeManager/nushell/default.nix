{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    nufmt
  ];
  programs.nushell.enable = true;
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
