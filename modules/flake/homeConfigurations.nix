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
            modules = [
              {
                home.username = username;
                home.homeDirectory = homeDirectory;
              }
              ((import ../../home-manager/nixPath.nix) {
                nixpkgs = inputs.nixpkgs-mine;
              })
              ((import ../../home-manager/nixd.nix) {
                hostname = hostname;
              })
              ((import ../../home-manager/catppuccin.nix) inputs.catppuccin)
              ((import ../../home-manager/nix-index-database.nix) inputs.nix-index-database)
              ((import ../../home-manager/sops-nix.nix) inputs.sops-nix)
              ((import ../../home-manager/mcp-servers-nix.nix) inputs.mcp-servers-nix)
              ((import ../../home-manager/nur.nix) inputs.nur)
              ((import ../../home-manager/android-nixpkgs.nix) inputs.android-nixpkgs)
              ../../home-manager
            ];
          })
        );
      }
    ))
    lib.attrsets.mergeAttrsList
  ];
}
