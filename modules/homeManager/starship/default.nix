{ config, lib, ... }:
{
  programs.starship.enable = true;
  programs.starship.enableBashIntegration = true;
  programs.starship.enableFishIntegration = true;
  programs.starship.enableNushellIntegration = true;
  programs.starship.enableZshIntegration = true;
  programs.x-elvish.rcExtra = ''
    eval (${config.programs.starship.package}/bin/starship init elvish)
  '';
  programs.starship.settings = lib.importTOML ./config/starship.toml;
}
