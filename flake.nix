{
  inputs = {
    # Using channel has a higher possibility that the packages are available at https://cache.nixos.org
    nixpkgs-mine.url = "https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz";

    flake-parts.url = "github:hercules-ci/flake-parts";

    # platform-tools 37.0.0 was first available on 2026-03-03
    # However, the hash of https://dl.google.com/android/repository/platform-tools_r37.0.0-darwin.zip changed on 2026-04-15
    #
    # It is intentionally that we DO NOT override the input `nixpkgs` of `android-nixpkgs`.
    # Otherwise, every time we update `nixpkgs`, the whole Android SDK has to be re-downloaded.
    android-nixpkgs.url = "github:tadfisher/android-nixpkgs/2026-04-15-stable";

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs-mine";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-mine";
    };
    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs-mine";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-mine";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs-mine";
      inputs.flake-parts.follows = "flake-parts";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-mine";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-mine";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs =
    inputs@{
      flake-parts,
      home-manager,
      nixpkgs-mine,
      nix-darwin,
      sops-nix,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      let
        machines = import ./machines.nix;
      in
      {
        systems = [ "aarch64-darwin" ];

        imports = [
          home-manager.flakeModules.home-manager
          ./modules/flake-parts/formatter.nix
          ./modules/flake-parts/homeConfigurations.nix
        ];

        perSystem =
          { system, ... }:
          {
            _module.args.pkgs = nixpkgs-mine.legacyPackages.${system}; # FIXME: This can be out-of-sync with `homeManagerConfiguration { pkgs }`.
          };

        flake = {
          tests = {
            md5toUUID = import ./lib/md5toUUID.test.nix;
            userscript_metadata_block = import ./lib/userscript_metadata_block/default.test.nix;
          };

          darwinConfigurations = nixpkgs-mine.lib.pipe machines [
            (builtins.map (
              {
                hostname,
                system,
                username,
                ...
              }:
              {
                "${hostname}" = nix-darwin.lib.darwinSystem {
                  modules = [
                    {
                      nixpkgs.hostPlatform = system;
                      system.primaryUser = username;
                    }
                    ((import ./nix-darwin/homebrew.nix) {
                      inherit nix-homebrew homebrew-core homebrew-cask;
                    })
                    ((import ./nix-darwin/karabiner.nix) nix-darwin)
                    ./nix-darwin
                  ];
                };
              }
            ))
            nixpkgs-mine.lib.attrsets.mergeAttrsList
          ];

          nixosConfigurations.nas = nixpkgs-mine.lib.nixosSystem {
            modules = [
              ./nas
              sops-nix.nixosModules.sops
            ];
          };
        };
      }
    );
}
