{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nodejs
    yarn

    playwright
    playwright-test
  ];

  home.sessionVariables = {
    # playwright-test depends on playwright
    # So we add it to module.paths so that the global installation of nodejs can load playwright directly.
    # https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/development/web/playwright/driver.nix#L185
    NODE_PATH = "${pkgs.lib.makeSearchPath "lib/node_modules" (
      with pkgs;
      [
        "${playwright-test}"
      ]
    )}";
  };
}
