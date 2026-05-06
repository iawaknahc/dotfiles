{
  inputs,
  lib,
  withSystem,
  ...
}:
let
  machines = import ../../machines.nix;
in
{
  flake.homeConfigurations = lib.pipe machines [
    (builtins.map (
      {
        hostname,
        username,
        homeDirectory,
        # Note that `system` is from `machines`, not from flake-parts.
        # I aware there exists `moduleWithSystem`,
        # but `homeConfigurations` are not modules, so it is inapplicable.
        system,
        ...
      }:
      {
        # home-manager will try homeConfigurations.username@hostname, and then homeConfigurations.username.
        "${username}@${hostname}" = withSystem system (
          { pkgs, ... }:
          (inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { inherit inputs hostname; };
            modules = [
              {
                home.username = username;
                home.homeDirectory = homeDirectory;
              }
              ../../home-manager/nixPath.nix
              ../../home-manager/nixd.nix
              ../../home-manager/catppuccin.nix
              ../../home-manager/nix-index-database.nix
              ../../home-manager/sops-nix.nix
              ../../home-manager/mcp-servers-nix.nix
              ../../home-manager/nur.nix
              ../../home-manager/android-nixpkgs.nix
              ../../home-manager
            ];
          })
        );
      }
    ))
    lib.attrsets.mergeAttrsList
  ];
}
