{
  nixpkgs,
}:
_:
let
  flake = "${../.}";
in
{
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
  ];

  programs.fish.shellAbbrs = {
    # Launch `nix repl` having `pkgs` with all overlays applied.
    # We use environment variable here so that the repl is never stale.
    nixrepl = ''nix repl --expr '(builtins.getFlake ((builtins.getEnv "HOME") + "/dotfiles")).homeConfigurations."nixd@nixd".pkgs' '';
  };

  xdg.configFile."nvim/lsp/nixd.lua".text = ''
    return {
      -- Known issue: inlay hint works only in `with pkgs; [ ... ]`
      -- See https://github.com/nix-community/nixd/issues/629#issuecomment-2558520043
      cmd = { "nixd", "--inlay-hints=true", "--semantic-tokens=true" },
      settings = {
        nixd = {
          formatting = {
            command = { "nixfmt" },
          },
          nixpkgs = {
            -- This evaluates to the actual pkgs with all overlays applied.
            expr = [[(builtins.getFlake (builtins.toString "${flake}")).homeConfigurations."nixd@nixd".pkgs]],
          },
          options = {
            ["nix-darwin"] = {
              expr = [[(builtins.getFlake (builtins.toString "${flake}")).darwinConfigurations.nixd.options]],
            },
            ["home-manager"] = {
              expr = [[(builtins.getFlake (builtins.toString "${flake}")).homeConfigurations."nixd@nixd".options]],
            },
          },
        },
      },
    }
  '';
}
