{ withSystem, ... }: # This scope is in `flake` module.
let
  UAX44-ucd = { callPackage }: callPackage ../../packages/UAX44-ucd.nix { };
  UTS39-security = { callPackage }: callPackage ../../packages/UTS39-security.nix { };
  UTS46-idna = { callPackage }: callPackage ../../packages/UTS46-idna.nix { };
  UTS51-emoji = { callPackage }: callPackage ../../packages/UTS51-emoji.nix { };
  UTS58-linkification = { callPackage }: callPackage ../../packages/UTS58-linkification.nix { };
  nu_plugin_dt = { callPackage }: callPackage ../../packages/nu_plugin_dt.nix { };
  nu_plugin_regex = { callPackage }: callPackage ../../packages/nu_plugin_regex.nix { };
  alfred-workflow-switch-appearance =
    { callPackage }: callPackage ../../packages/alfred-workflow-switch-appearance.nix { };
  EmmyLua_spoon = { callPackage }: callPackage ../../packages/EmmyLua_spoon.nix { };
  tree-sitter-numbat = { callPackage }: callPackage ../../packages/tree-sitter-numbat.nix { };
  nvim-colors = { callPackage }: callPackage ../../packages/nvim-colors.nix { };
  my-ggufs = { callPackage }: callPackage ../../packages/my-ggufs.nix { };
  hledger-lsp = { callPackage }: callPackage ../../packages/hledger-lsp.nix { };
  py2hy = { callPackage }: callPackage ../../packages/py2hy.nix { };
  beancount2ledger = { callPackage }: callPackage ../../packages/beancount2ledger.nix { };
  autobean_refactor = { callPackage }: callPackage ../../packages/autobean_refactor.nix { };
  autobean_format = { callPackage }: callPackage ../../packages/autobean_format.nix { };
  pyxirr = { callPackage }: callPackage ../../packages/pyxirr.nix { };
  rassumfrassum = { callPackage }: callPackage ../../packages/rassumfrassum.nix { };
in
{
  # Add packages to this flake.
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        UAX44-ucd = UAX44-ucd { callPackage = pkgs.callPackage; };
        UTS39-security = UTS39-security { callPackage = pkgs.callPackage; };
        UTS46-idna = UTS46-idna { callPackage = pkgs.callPackage; };
        UTS51-emoji = UTS51-emoji { callPackage = pkgs.callPackage; };
        UTS58-linkification = UTS58-linkification { callPackage = pkgs.callPackage; };
        nu_plugin_dt = nu_plugin_dt { callPackage = pkgs.callPackage; };
        nu_plugin_regex = nu_plugin_regex { callPackage = pkgs.callPackage; };
        alfred-workflow-switch-appearance = alfred-workflow-switch-appearance {
          callPackage = pkgs.callPackage;
        };
        EmmyLua_spoon = EmmyLua_spoon { callPackage = pkgs.callPackage; };
        tree-sitter-numbat = tree-sitter-numbat { callPackage = pkgs.callPackage; };
        nvim-colors = nvim-colors { callPackage = pkgs.callPackage; };
        my-ggufs = my-ggufs { callPackage = pkgs.callPackage; };
        hledger-lsp = hledger-lsp { callPackage = pkgs.callPackage; };

        py2hy = py2hy { callPackage = pkgs.python3Packages.callPackage; };
        beancount2ledger = beancount2ledger { callPackage = pkgs.python3Packages.callPackage; };
        autobean_refactor = autobean_refactor { callPackage = pkgs.python3Packages.callPackage; };
        autobean_format = autobean_format { callPackage = pkgs.python3Packages.callPackage; };
        pyxirr = pyxirr { callPackage = pkgs.python3Packages.callPackage; };
        rassumfrassum = rassumfrassum { callPackage = pkgs.python3Packages.callPackage; };
      };
    };

  # Expose the added packages as an overlay named `default`.
  flake.overlays.default =
    let
      packageOverrides = pyfinal: pyprev: {
        py2hy = py2hy { callPackage = pyfinal.callPackage; };
        beancount2ledger = beancount2ledger { callPackage = pyfinal.callPackage; };
        autobean_refactor = autobean_refactor { callPackage = pyfinal.callPackage; };
        autobean_format = autobean_format { callPackage = pyfinal.callPackage; };
        pyxirr = pyxirr { callPackage = pyfinal.callPackage; };
        rassumfrassum = rassumfrassum { callPackage = pyfinal.callPackage; };

        # The docs/ directory of beanquery will be copied to site-packages/
        # which will clash with The docs/ directory of https://github.com/pyca/cryptography/tree/48.0.0/docs
        #
        # I tried postBuild, preInstall, and postInstall.
        # They all did not work.
        # I haven't studied why it was the case.
        # But postPatch worked for me.
        # Maybe if postPatch is specified, the Python package will be built from source.
        beanquery = pyprev.beanquery.overrideAttrs {
          postPatch = ''
            rm -r ./docs
          '';
        };
      };
    in
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

        tree-sitter-numbat = config.packages.tree-sitter-numbat;

        nvim-colors = config.packages.nvim-colors;

        my-ggufs = config.packages.my-ggufs;

        hledger-lsp = config.packages.hledger-lsp;

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

        python311 = prev.python311.override {
          inherit packageOverrides;
        };

        python312 = prev.python312.override {
          inherit packageOverrides;
        };

        python313 = prev.python313.override {
          inherit packageOverrides;
        };

        python314 = prev.python314.override {
          inherit packageOverrides;
        };

        python315 = prev.python315.override {
          inherit packageOverrides;
        };
      }
    );
}
