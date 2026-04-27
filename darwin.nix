{
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

  security.pam.services.sudo_local.enable = true;
  security.pam.services.sudo_local.reattach = true;
  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.watchIdAuth = true;

  # On Android emulators, 10.0.2.2 is the host.
  # We alias 10.0.2.2 to the loopback interface of the host.
  # Thus, 10.0.2.2 always means the host.
  launchd.daemons."android-10.0.2.2" = {
    script = ''
      /sbin/ifconfig lo0 alias 10.0.2.2 255.255.255.255
    '';
    serviceConfig = {
      RunAtLoad = true;
    };
  };
}
