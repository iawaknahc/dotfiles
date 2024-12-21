{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      home-manager,
      mac-app-util,
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
                  nixpkgs
                  home-manager
                  username
                  homeDirectory
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
    };
}
