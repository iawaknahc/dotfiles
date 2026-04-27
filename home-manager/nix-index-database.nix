nix-index-database: _: {
  imports = [ nix-index-database.homeModules.default ];
  config = {
    programs.nix-index.enable = true; # Provide `nix-locate` to find which packages provide a certain file.
    programs.nix-index-database.comma.enable = false; # Provide `,` to run a command without installing it. I guess I don't need it for now.
  };
}
