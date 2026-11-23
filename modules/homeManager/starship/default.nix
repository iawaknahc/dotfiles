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
      # This issue has been fixed since fish shell 3.2.0
      # Issue 5880 mentions the same workaround Starship is using.
      # https://github.com/fish-shell/fish-shell/issues/5860#issuecomment-500593087
      # A maintainer said issue 5880 is a duplicate of issue 3550
      # https://github.com/fish-shell/fish-shell/issues/5860#issuecomment-751477264
      # In issue 3550, the maintainer said the bug was fixed since 3.2.0
      # https://github.com/fish-shell/fish-shell/issues/3550#issuecomment-751476180
      #
      # The workaround is causing problem in tmux.
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
