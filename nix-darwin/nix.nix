{
  nix.channel.enable = false;
  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.upgrade-nix-store-path-url = "https://install.determinate.systems/nix-upgrade/stable/universal";
}
