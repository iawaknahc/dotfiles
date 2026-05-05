{
  hostname,
}:
{ pkgs, config, ... }:
let
  flake = "${../.}";
in
{
  home.packages = with pkgs; [
    nixd
  ];
  home.shellAliases = {
    # Launch `nix repl` having `pkgs` with all overlays applied.
    # We use environment variable here so that the repl is never stale.
    nixrepl = ''nix repl --expr '(builtins.getFlake ((builtins.getEnv "HOME") + "/dotfiles")).homeConfigurations."${config.home.username}@${hostname}".pkgs' '';
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
            expr = [[(builtins.getFlake (builtins.toString "${flake}")).homeConfigurations."${config.home.username}@${hostname}".pkgs]],
          },
          options = {
            ["nix-darwin"] = {
              expr = [[(builtins.getFlake (builtins.toString "${flake}")).darwinConfigurations."${hostname}".options]],
            },
            ["home-manager"] = {
              expr = [[(builtins.getFlake (builtins.toString "${flake}")).homeConfigurations."${config.home.username}@${hostname}".options]],
            },
          },
        },
      },
    }
  '';
}
