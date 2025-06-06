{
  nixpkgsHostPlatform,
  pkgs,
  ...
}:
{
  nixpkgs.hostPlatform = nixpkgsHostPlatform;
  system.stateVersion = 5;

  nix.channel.enable = false;

  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.upgrade-nix-store-path-url = "https://install.determinate.systems/nix-upgrade/stable/universal";

  environment.variables = {
    # The default is "nano".
    # https://github.com/LnL7/nix-darwin/blob/master/modules/environment/default.nix#L208
    EDITOR = "vi";
    # The default is "less -R".
    # https://github.com/LnL7/nix-darwin/blob/master/modules/environment/default.nix#L209
    PAGER = "less -R";
  };

  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.fish.enable = true;
  programs.fish.useBabelfish = true;

  # security.pam.enableSudoTouchIdAuth = true;
  #
  # But this does not work for tmux.
  # See https://github.com/LnL7/nix-darwin/issues/985#issuecomment-2198113056
  #
  # Since macOS Sonoma, /etc/pam.d/sudo has a line to include /etc/pam.d/sudo_local
  # /etc/pam.d/sudo_local does not exist by default, so including a non-existent file is NOT an error.
  #
  # However, if /etc/pam.d/sudo_local is readable, then the contents of it must be valid, otherwise,
  # sudo will crash, and we cannot run sudo anymore.
  # Therefore, it is extremely important that we enable the root user first.
  # See https://support.apple.com/en-hk/102367 for how to do so.
  #
  # In case we mess up /etc/pam.d/sudo_local, we log in as root.
  # Then use Finder to delete /etc/pam.d/sudo_local.
  # A fun fact is that even when I am logging in as root,
  # if I use Terminal.app to rm /etc/pam.d/sudo_local, it still says permission denied.
  #
  # So, a relatively safe way to enable Touch ID with tmux support is make /etc/pam.d/sudo_local a symlink.
  # When it is a broken link, then it is NOT an error.
  # When it is not a broken link, then we trust that environment.etc generates a valid file.
  # This approach is also documented in this blogpost https://write.rog.gr/writing/using-touchid-with-tmux/#creating-a-etcpamdsudo_local-file-using-nix-darwin
  # A risk of this approach I can think of is that the package pam-reattach got an update, and the path to pam_reattach.so has changed.
  environment.etc."pam.d/sudo_local".text = ''
    # Generated by nix-darwin. DO NOT EDIT!
    auth  optional    ${pkgs.pam-reattach}/lib/pam/pam_reattach.so  ignore_ssh
    auth  sufficient  pam_tid.so
  '';
}
