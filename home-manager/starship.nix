{ config, ... }:
{
  programs.starship.enable = true;
  programs.starship.enableBashIntegration = true;
  programs.starship.enableFishIntegration = true;
  programs.starship.enableIonIntegration = false;
  programs.starship.enableNushellIntegration = true;
  programs.starship.enableZshIntegration = true;
  programs.x-elvish.rcExtra = ''
    eval (${config.programs.starship.package}/bin/starship init elvish)
  '';
  xdg.configFile."starship.toml" = {
    enable = true;
    source = ../.config/starship.toml;
  };
}
