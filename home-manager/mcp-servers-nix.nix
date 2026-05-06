{ inputs, ... }:
{
  nixpkgs.overlays = [
    inputs.mcp-servers-nix.overlays.default
  ];
}
