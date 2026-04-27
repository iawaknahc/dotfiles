nix-darwin:
{ pkgs, ... }:
{
  assertions = [
    {
      assertion =
        builtins.convertHash {
          hash = builtins.hashFile "sha256" "${nix-darwin.outPath}/modules/services/karabiner-elements/default.nix";
          hashAlgo = "sha256";
          toHashFormat = "sri";
        } == "sha256-LunW4grq259/PHoW5nD8PJA2PidN4gF7SX9Ctoz6ens=";
      message = "modules/services/karabiner-elements.default.nix has changes. Maybe https://github.com/nix-darwin/nix-darwin/issues/1041 has been fixed.";
    }
  ];

  services.karabiner-elements.enable = true;
  # FIXME: The karabiner module on nix-darwin does not support v15.
  # https://github.com/nix-darwin/nix-darwin/issues/1041#issuecomment-2889787482
  services.karabiner-elements.package = pkgs.karabiner-elements.overrideAttrs (old: {
    version = "14.13.0";
    src = pkgs.fetchurl {
      inherit (old.src) url;
      hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
    };
    dontFixup = true;
  });
}
