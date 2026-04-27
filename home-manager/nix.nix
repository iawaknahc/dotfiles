{ pkgs, ... }:
{
  assertions = [
    {
      assertion = pkgs.nix-output-monitor.version == "2.1.8";
      message = "The workaround for nix-output-monitor@2.1.8 may no longer needed. Consider removing it.";
    }
  ];
  # As of 2026-03-30, the latest release 2.1.8 (released on 2025-11-09) of nix-output-monitor does not show download progress.
  # The commit https://github.com/maralorn/nix-output-monitor/commit/0cb46615fb8187e4598feac4ccf8f27a06aae0b7 made on 2025-11-20 does that.
  nixpkgs.overlays = [
    (final: prev: {
      nix-output-monitor = prev.nix-output-monitor.overrideAttrs {
        src = prev.fetchFromGitHub {
          owner = "maralorn";
          repo = "nix-output-monitor";
          rev = "4c34e115ab344df485316d4a61768b8d561fbeb3";
          hash = "sha256-CcdGDNLkCsncYI+S5O71YgxQm2XLD8zPiDQQIebEdJ0=";
        };
      };
    })
  ];

  home.packages = with pkgs; [
    flake-checker
    nurl
    nix-melt
    nix-tree
    nix-unit
    nixfmt
    nil
  ];
  programs.nix-init.enable = true;
  programs.nh.enable = true;
}
