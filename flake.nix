{
  inputs = {
    # Using channel has a higher possibility that the packages are available at https://cache.nixos.org
    nixpkgs-mine.url = "https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz";

    android-nixpkgs = {
      # platform-tools 37.0.0 was first available on 2026-03-03
      # However, the hash of https://dl.google.com/android/repository/platform-tools_r37.0.0-darwin.zip changed on 2026-04-15
      url = "github:tadfisher/android-nixpkgs/2026-04-15-stable";
      # It is intentionally that we DO NOT override the input `nixpkgs` of `android-nixpkgs`.
      # Otherwise, every time we update `nixpkgs`, the whole Android SDK has to be re-downloaded.
      inputs.flake-utils.follows = "flake-utils";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs-mine";
    };
    flake-utils.url = "github:numtide/flake-utils";
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
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-mine";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-mine";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-mine";
    };
  };

  outputs =
    {
      nixpkgs-mine,
      android-nixpkgs,
      catppuccin,
      flake-utils,
      home-manager,
      mcp-servers-nix,
      nix-darwin,
      nur,
      sops-nix,
      nix-index-database,
      ...
    }:
    let
      machines = import ./machines.nix;
    in
    {
      tests = {
        md5toUUID = import ./lib/md5toUUID.test.nix;
        userscript_metadata_block = import ./lib/userscript_metadata_block/default.test.nix;
      };

      formatter = flake-utils.lib.eachDefaultSystemPassThrough (system: {
        "${system}" = nixpkgs-mine.legacyPackages.${system}.nixfmt-tree;
      });

      homeConfigurations = nixpkgs-mine.lib.pipe machines [
        (builtins.map (
          {
            hostname,
            system,
            username,
            homeDirectory,
          }:
          {
            # home-manager will try homeConfigurations.username@hostname, and then homeConfigurations.username.
            "${username}@${hostname}" = home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs-mine.legacyPackages.${system};
              modules = [
                {
                  home.username = username;
                  home.homeDirectory = homeDirectory;
                }
                ((import ./home-manager/nixPath.nix) {
                  inherit home-manager nix-darwin;
                  nixpkgs = nixpkgs-mine;
                })
                ((import ./home-manager/catppuccin.nix) catppuccin)
                ((import ./home-manager/nix-index-database.nix) nix-index-database)
                ((import ./home-manager/sops-nix.nix) sops-nix)
                ((import ./home-manager/mcp-servers-nix.nix) mcp-servers-nix)
                ((import ./home-manager/nur.nix) nur)
                ((import ./home-manager/android-nixpkgs.nix) android-nixpkgs)
                ./home-manager
              ];
            };
          }
        ))
        nixpkgs-mine.lib.attrsets.mergeAttrsList
      ];

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
                ((import ./nix-darwin/karabiner.nix) nix-darwin)
                ./darwin.nix
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
