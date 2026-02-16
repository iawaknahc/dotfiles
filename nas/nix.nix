{ ... }:
{
  system.stateVersion = "25.11";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Usage:
  #   nh os switch
  programs.nh.enable = true;
  programs.nh.flake = "/home/nixos/dotfiles";
}
