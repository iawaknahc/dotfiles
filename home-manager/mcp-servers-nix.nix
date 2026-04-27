mcp-servers-nix: _: {
  nixpkgs.overlays = [
    mcp-servers-nix.overlays.default
  ];
}
