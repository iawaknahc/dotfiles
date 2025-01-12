{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      home-manager,
      nix-darwin,
      mac-app-util,
      android-nixpkgs,
      ...
    }:
    let
      machines = [
        {
          hostname = "louischan-m4";
          system = "aarch64-darwin";
          username = "louischan";
          homeDirectory = "/Users/louischan";
        }
        {
          hostname = "louischan-work";
          system = "aarch64-darwin";
          username = "louischan";
          homeDirectory = "/Users/louischan";
        }
      ];
    in
    {
      formatter = flake-utils.lib.eachDefaultSystem (
        system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style
      );
      # home-manager will try homeConfigurations.username@hostname, and then homeConfigurations.username.
      homeConfigurations = nixpkgs.lib.pipe machines [
        (builtins.map (
          {
            hostname,
            system,
            username,
            homeDirectory,
          }:
          {
            "${username}@${hostname}" = home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.${system};
              extraSpecialArgs = {
                inherit
                  username
                  homeDirectory
                  android-nixpkgs
                  ;
              };
              modules = [
                mac-app-util.homeManagerModules.default
                ./home.nix
              ];
            };
          }
        ))
        nixpkgs.lib.attrsets.mergeAttrsList
      ];
      darwinConfigurations = nixpkgs.lib.pipe machines [
        (builtins.map (
          {
            hostname,
            system,
            ...
          }:
          {
            "${hostname}" = nix-darwin.lib.darwinSystem {
              modules = [ ./darwin.nix ];
              specialArgs = {
                inherit nixpkgs home-manager nix-darwin;
                nixpkgsHostPlatform = system;
                darwin-config = ./darwin.nix;
              };
            };
          }
        ))
        nixpkgs.lib.attrsets.mergeAttrsList
      ];
    };
}
