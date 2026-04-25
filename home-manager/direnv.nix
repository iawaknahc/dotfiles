{
  pkgs,
  config,
  lib,
  ...
}:
{
  programs.direnv.enable = true;
  # FIXME: direnv fails to build. See https://github.com/NixOS/nixpkgs/issues/513019
  programs.direnv.package = pkgs.direnv.overrideAttrs {
    doCheck = false;
  };
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.enableBashIntegration = true;
  programs.direnv.enableFishIntegration = true;
  programs.direnv.enableNushellIntegration = true;
  programs.direnv.enableZshIntegration = true;
  programs.x-elvish.rcExtra = lib.mkAfter ''
    eval (${config.programs.direnv.package}/bin/direnv hook elvish | slurp)
  '';
  programs.git.ignores = [
    ".envrc"
    ".direnv/"
  ];
}
