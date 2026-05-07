{ withSystem, ... }: # This scope is in `flake` module.
{
  # Add packages to this flake.
  perSystem =
    { pkgs, ... }:
    {
      packages.UAX44-ucd = pkgs.callPackage ../../packages/UAX44-ucd.nix { };
      packages.UTS39-security = pkgs.callPackage ../../packages/UTS39-security.nix { };
      packages.UTS46-idna = pkgs.callPackage ../../packages/UTS46-idna.nix { };
      packages.UTS51-emoji = pkgs.callPackage ../../packages/UTS51-emoji.nix { };
      packages.UTS58-linkification = pkgs.callPackage ../../packages/UTS58-linkification.nix { };
    };

  # Expose the added packages as an overlay named `default`.
  flake.overlays.default =
    final: prev:
    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }: # `withSystem` brings us to the scope of `perSystem` module. So `config` refers to `perSystem.config`.
      {
        UAX44-ucd = config.packages.UAX44-ucd;
        UTS39-security = config.packages.UTS39-security;
        UTS46-idna = config.packages.UTS46-idna;
        UTS51-emoji = config.packages.UTS51-emoji;
        UTS58-linkification = config.packages.UTS58-linkification;
      }
    );
}
