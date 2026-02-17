{
  config,
  lib,
  ...
}:
{
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.enableBashIntegration = true;
  programs.direnv.enableFishIntegration = true;
  programs.direnv.enableNushellIntegration = true;
  programs.direnv.enableZshIntegration = true;
  programs.x-elvish.rcExtra = lib.mkAfter ''
    eval (${config.programs.direnv.package}/bin/direnv hook elvish | slurp)
  '';
}
