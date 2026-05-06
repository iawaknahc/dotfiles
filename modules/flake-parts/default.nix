{ inputs, ... }:
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
  ];

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = inputs.nixpkgs-mine.legacyPackages.${system};
    };
}
