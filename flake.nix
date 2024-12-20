{
  inputs = {
    # Track the rolling release.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      mac-app-util,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      machines = [
        {
          hostname = "louischan-m4";
          system = "aarch64-darwin";
          username = "louischan";
        }
        {
          hostname = "louischan-work";
          system = "aarch64-darwin";
          username = "louischan";
        }
      ];
    in
    {
      formatter = nixpkgs.lib.attrsets.genAttrs systems (
        system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style
      );
      # home-manager will try homeConfigurations.username@hostname, and then homeConfigurations.username.
      homeConfigurations = nixpkgs.lib.pipe machines [
        (builtins.map (
          {
            hostname,
            username,
            system,
          }:
          {
            "${username}@${hostname}" = home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.${system};
              extraSpecialArgs = {
                inherit nixpkgs;
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
