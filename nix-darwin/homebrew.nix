{
  nix-homebrew,
  homebrew-core,
  homebrew-cask,
}:
{ config, ... }:
{
  imports = [ nix-homebrew.darwinModules.nix-homebrew ];
  config = {
    nix-homebrew.enable = true;
    nix-homebrew.enableRosetta = false;
    nix-homebrew.user = config.system.primaryUser;
    nix-homebrew.taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };
    nix-homebrew.mutableTaps = false;
    nix-homebrew.enableBashIntegration = false;
    nix-homebrew.enableFishIntegration = false;
    nix-homebrew.enableZshIntegration = false;

    homebrew.enable = true;
    homebrew.global.autoUpdate = false;
    homebrew.onActivation.cleanup = "zap";
    homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
    homebrew.casks = [
      { name = "1password"; }
      { name = "alfred"; }
      { name = "claude"; }
      { name = "docker"; }
      { name = "firefox"; }
      { name = "google-chrome"; }
      { name = "ledger-wallet"; }
      { name = "libreoffice"; }
      { name = "localsend"; }
      { name = "obs"; }
      { name = "obsidian"; }
      { name = "protonvpn"; }
      { name = "steam"; }
      { name = "tailscale-app"; }
    ];
  };
}
