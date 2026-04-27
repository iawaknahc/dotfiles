{
  nixpkgs,
  home-manager,
  nix-darwin,
}:
_: {
  # Set NIX_PATH
  # nix-darwin also offers a similar option but we do this in home-manager because
  # nix-darwin only supports a limited number of shells.
  # nix.nixPath in home-manager is implemented by home.sessionVariables, and
  # we expect the shell module supports home.sessionVariables, like ./home-manager/x-elvish.nix
  nix.keepOldNixPath = false;
  nix.nixPath = [
    "nixpkgs=${nixpkgs.outPath}"
    "home-manager=${home-manager.outPath}"
    "nix-darwin=${nix-darwin.outPath}"
    "darwin-config=${../darwin.nix}"
    "for-nixd=${../.}"
  ];
}
