{ inputs, self, ... }:
{
  systems = [ "aarch64-darwin" ];

  imports = [
    inputs.home-manager.flakeModules.home-manager
    inputs.nix-darwin.flakeModules.default
    inputs.nix-unit.modules.flake.default

    ./formatter.nix
    ./homeConfigurations.nix
    ./darwinConfigurations.nix
    ./nixosConfigurations.nix
    ./tests.nix
    ./packages.nix
  ];

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs-mine {
        inherit system;
        overlays = [
          inputs.nur.overlays.default

          # Apply the overlay `default` exposed by this flake.
          self.overlays.default
        ];
      };
    };
}
