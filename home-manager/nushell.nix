{ pkgs, config, ... }:
{
  programs.nushell.enable = true;
  programs.nushell.shellAliases = config.home.shellAliases;
  programs.nushell.envFile.source = ../.config/nushell/env.nu;
  programs.nushell.configFile.source = ../.config/nushell/config.nu;
  # Install official plugins.
  programs.nushell.plugins = [
    pkgs.nushellPlugins.polars
    pkgs.nushellPlugins.formats
    pkgs.nushellPlugins.gstat
    pkgs.nushellPlugins.query
  ];
  programs.carapace.enable = true;
  programs.carapace.enableBashIntegration = false;
  programs.carapace.enableFishIntegration = false;
  programs.carapace.enableNushellIntegration = true;
  programs.carapace.enableZshIntegration = false;
}
