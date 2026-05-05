{
  inputs,
  ...
}:
{
  # The module argument `lib` of flake-parts does not have `lib.nixosSystem` because it is from `nixpkgs-lib`.
  # So we have to read from `nixpkgs.lib.nixosSystem`.
  flake.nixosConfigurations.nas = inputs.nixpkgs-mine.lib.nixosSystem {
    modules = [
      inputs.sops-nix.nixosModules.sops

      ../../nas
    ];
  };
}
