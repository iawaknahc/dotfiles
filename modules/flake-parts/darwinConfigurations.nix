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
          modules = [
            {
              nixpkgs.hostPlatform = system;
              system.primaryUser = username;
            }
            ((import ../../nix-darwin/homebrew.nix) {
              inherit (inputs) nix-homebrew homebrew-core homebrew-cask;
            })
            ((import ../../nix-darwin/karabiner.nix) inputs.nix-darwin)
            ../../nix-darwin
          ];
        };
      }
    ))
    lib.attrsets.mergeAttrsList
  ];
}
