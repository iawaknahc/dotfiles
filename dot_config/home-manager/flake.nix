{
  inputs = {
    # Track the rolling release.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      mkConfig = { system }:
      let pkgs = nixpkgs.legacyPackages.${system};
      in home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    in {
      formatter = nixpkgs.lib.attrsets.genAttrs systems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
      # home-manager will try homeConfigurations.username@hostname, and then homeConfigurations.username.
      homeConfigurations."louischan@louischan-m4" = mkConfig { system = "aarch64-darwin"; };
      homeConfigurations."louischan@louischan-work" = mkConfig { system = "aarch64-darwin"; };
    };
}
