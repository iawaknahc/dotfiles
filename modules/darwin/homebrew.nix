{ inputs, config, ... }:
{
  imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];
  config = {
    nix-homebrew.enable = true;
    nix-homebrew.enableRosetta = false;
    nix-homebrew.user = config.system.primaryUser;
    nix-homebrew.taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
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
      # As of Nix 26.05, the package of OBS Studio on Nixpkgs does not support macOS.
      # See https://github.com/NixOS/nixpkgs/blob/nixpkgs-26.05-darwin/pkgs/applications/video/obs-studio/default.nix#L262
      { name = "obs"; }
      { name = "protonvpn"; }
      { name = "steam"; }
      { name = "tailscale-app"; }
    ];
  };
}
