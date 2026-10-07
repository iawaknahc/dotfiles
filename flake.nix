{
  inputs = {
    # Visit https://nixos.org/channels/nixos-unstable
    # The URL will resolve to something like https://releases.nixos.org/nixos/unstable/nixos-26.11pre1086391.151fa4e8ddfd
    # 151fa4e8ddfd is a Git commit hash https://github.com/NixOS/nixpkgs/commits/151fa4e8ddfdd8dd25d945ad94ed54a13de9f6e4
    # The release appearing on https://releases.nixos.org has a higher possibility that the packages are cached on https://cache.nixos.org
    nixpkgs-mine.url = "https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz";

    flake-parts.url = "github:hercules-ci/flake-parts";

    # platform-tools 37.0.0 was first available on 2026-03-03
    # However, the hash of https://dl.google.com/android/repository/platform-tools_r37.0.0-darwin.zip changed on 2026-04-15
    #
    # It is intentionally that we DO NOT override the input `nixpkgs` of `android-nixpkgs`.
    # Otherwise, every time we update `nixpkgs`, the whole Android SDK has to be re-downloaded.
    android-nixpkgs.url = "github:tadfisher/android-nixpkgs/2026-04-15-stable";

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs-mine";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-mine";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-mine";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs-mine";
      inputs.flake-parts.follows = "flake-parts";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-mine";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-mine";
    };
    nix-unit = {
      url = "github:nix-community/nix-unit";
      inputs.nixpkgs.follows = "nixpkgs-mine";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } (import ./modules/flake);
}
