{ inputs, lib, ... }:
let
  machines = import ../../machines.nix;
in
{
  flake.darwinConfigurations = lib.pipe machines [
    (builtins.map (
      {
        hostname,
        system,
        username,
        ...
      }:
      {
        "${hostname}" = inputs.nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs; };
          modules = [
            {
              nixpkgs.hostPlatform = system;
              system.primaryUser = username;
            }
            ../../nix-darwin/homebrew.nix
            ../../nix-darwin/karabiner.nix
            ../../nix-darwin
          ];
        };
      }
    ))
    lib.attrsets.mergeAttrsList
  ];
}
