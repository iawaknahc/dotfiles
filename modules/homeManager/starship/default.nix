{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.starship.enable = true;
  programs.starship.package = pkgs.starship.overrideAttrs (prev: {
    patches = (prev.patches or [ ]) ++ [
      # Starship prints ESC[J (clear to end of screen) specifically for fish shell.
      # See https://github.com/starship/starship/blob/v1.27.0/src/print.rs#L109
      #
      # This behavior was introduced in 2019.
      # See https://github.com/starship/starship/pull/739
      # Since then, it was modified a few times
      # 1. https://github.com/starship/starship/pull/865
      # 2. https://github.com/starship/starship/pull/3588
      #
      # In my testing with fish shell 4.9.3, this behavior seems no longer needed.
      # Even worse, this behavior is causing problem in tmux.
      # ESC[J will cause tmux to clear the OSC 133 A.
      ./remove-fish-clear-screen.patch
    ];
  });
  programs.starship.enableBashIntegration = true;
  programs.starship.enableFishIntegration = true;
  programs.starship.enableNushellIntegration = true;
  programs.starship.enableZshIntegration = true;
  programs.x-elvish.rcExtra = ''
    eval (${config.programs.starship.package}/bin/starship init elvish)
  '';
  programs.starship.settings = lib.importTOML ./config/starship.toml;
}
