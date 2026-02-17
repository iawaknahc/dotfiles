{ pkgs, ... }:
let
  carapace = pkgs.carapace;
in
{
  programs.carapace.enable = true;
  programs.carapace.package = carapace;
  programs.carapace.enableBashIntegration = true;
  programs.carapace.enableFishIntegration = true;
  programs.carapace.enableNushellIntegration = true;
  programs.carapace.enableZshIntegration = true;
  programs.x-elvish.rcExtra = ''
    eval (${carapace}/bin/carapace _carapace | slurp)
  '';

  home.sessionVariables = {
    "CARAPACE_BRIDGES" = "zsh,fish,bash";
  };
}
