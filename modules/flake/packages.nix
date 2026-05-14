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

      packages.nu_plugin_dt = pkgs.callPackage ../../packages/nu_plugin_dt.nix { };
      packages.nu_plugin_regex = pkgs.callPackage ../../packages/nu_plugin_regex.nix { };

      packages.alfred-workflow-switch-appearance =
        pkgs.callPackage ../../packages/alfred-workflow-switch-appearance.nix
          { };

      packages.EmmyLua_spoon = pkgs.callPackage ../../packages/EmmyLua_spoon.nix { };

      packages.py2hy = pkgs.python313Packages.callPackage ../../packages/py2hy.nix { };

      packages.tree-sitter-numbat = pkgs.callPackage ../../packages/tree-sitter-numbat.nix { };

      packages.nvim-colors = pkgs.callPackage ../../packages/nvim-colors.nix { };

      packages.my-ggufs = pkgs.callPackage ../../packages/my-ggufs.nix { };
    };

  # Expose the added packages as an overlay named `default`.
  flake.overlays.default =
    final: prev:
    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }: # `withSystem` brings us to the scope of `perSystem` module. So `config` refers to `perSystem.config`.
      rec {
        UAX44-ucd = config.packages.UAX44-ucd;
        UTS39-security = config.packages.UTS39-security;
        UTS46-idna = config.packages.UTS46-idna;
        UTS51-emoji = config.packages.UTS51-emoji;
        UTS58-linkification = config.packages.UTS58-linkification;

        nu_plugin_dt = config.packages.nu_plugin_dt;
        nu_plugin_regex = config.packages.nu_plugin_regex;

        alfred-workflow-switch-appearance = config.packages.alfred-workflow-switch-appearance;

        EmmyLua_spoon = config.packages.EmmyLua_spoon;

        py2hy = config.packages.py2hy;

        tree-sitter-numbat = config.packages.tree-sitter-numbat;

        nvim-colors = config.packages.nvim-colors;

        my-ggufs = config.packages.my-ggufs;

        hammerspoon-cli = prev.stdenv.mkDerivation {
          name = "hammerspoon-cli";
          pname = "hammerspoon-cli";
          src = builtins.toPath "${final.nur.repos.natsukium.hammerspoon}";
          installPhase = ''
            mkdir -p $out/bin
            mkdir -p $out/share/man/man1
            cp ./Applications/Hammerspoon.app/Contents/Frameworks/hs/hs $out/bin/
            cp ./Applications/Hammerspoon.app/Contents/Resources/man/hs.man $out/share/man/man1/hs.1
          '';
        };

        hammerspoon = prev.symlinkJoin {
          name = final.nur.repos.natsukium.hammerspoon.name;
          paths = [
            hammerspoon-cli
            final.nur.repos.natsukium.hammerspoon
          ];
        };
      }
    );
}
