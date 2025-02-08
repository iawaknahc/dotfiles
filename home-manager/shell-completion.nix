{ pkgs, ... }:
{
  home.sessionVariables = {
    "CARAPACE_BRIDGES" = "zsh,fish,bash,inshellisense";
  };
  home.packages = with pkgs; [
    inshellisense
  ];
  programs.carapace.enable = true;
  programs.carapace.enableBashIntegration = true;
  programs.carapace.enableFishIntegration = true;
  programs.carapace.enableNushellIntegration = true;
  programs.carapace.enableZshIntegration = true;
}
