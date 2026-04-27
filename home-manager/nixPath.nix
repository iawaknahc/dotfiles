{
  nixpkgs,
}:
_: {
  # Set NIX_PATH
  # nix-darwin also offers a similar option but we do this in home-manager because
  # nix-darwin only supports a limited number of shells.
  # nix.nixPath in home-manager is implemented by home.sessionVariables, and
  # we expect the shell module supports home.sessionVariables, like ./home-manager/x-elvish.nix
  nix.keepOldNixPath = false;
  nix.nixPath = [
    # Keep nixpkgs in NIX_PATH for compatibility with any other things depending on it.
    # We do not use it though.
    "nixpkgs=${nixpkgs.outPath}"
    # The store path to our flake.
    # It is used to configure nixd, as well as the following fish shell abbreviation to launch `nix repl`.
    "for-nixd=${../.}"
  ];

  programs.fish.shellAbbrs = {
    # Launch `nix repl` having `pkgs` with all overlays applied.
    nixrepl = ''nix repl --expr '(builtins.getFlake (builtins.toString <for-nixd>)).homeConfigurations."nixd@nixd".pkgs' '';
  };
}
