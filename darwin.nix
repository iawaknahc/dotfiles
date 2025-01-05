{ nixpkgsHostPlatform, ... }:
{
  nixpkgs.hostPlatform = nixpkgsHostPlatform;
  system.stateVersion = 5;

  services.nix-daemon.enable = true;

  nix.channel.enable = false;
  nix.nixPath = [ ];
  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.upgrade-nix-store-path-url = "https://install.determinate.systems/nix-upgrade/stable/universal";

  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.fish.enable = true;
  programs.fish.useBabelfish = true;
}
