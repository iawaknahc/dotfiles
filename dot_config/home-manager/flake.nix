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
    let mkConfig = { system }:
      let pkgs = nixpkgs.legacyPackages.${system};
      in home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    in {
      # home-manager will try homeConfigurations.username@hostname, and then homeConfigurations.username.
      homeConfigurations."louischan@louischan-personal" = mkConfig { system = "x86_64-darwin"; };
      homeConfigurations."louischan@louischan" = mkConfig { system = "aarch64-darwin"; };
    };
}
