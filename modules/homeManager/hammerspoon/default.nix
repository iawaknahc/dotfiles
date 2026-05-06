{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (
      final: prev:
      let
        hammerspoon-cli = prev.stdenv.mkDerivation {
          name = "hammerspoon-cli";
          pname = "hammerspoon-cli";
          src = builtins.toPath "${final.nur.repos.natsukium.hammerspoon}";
          installPhase = ''
            mkdir -p $out/bin
            mkdir -p $out/share/man/man1
            cp ./Applications/Hammerspoon.app/Contents/Frameworks/hs/hs $out/bin/
            cp ./Applications/Hammerspoon.app/Contents/Resources/man/hs.man $out/share/man/man1/hs.1
          '';
        };
      in
      {
        hammerspoon = prev.symlinkJoin {
          name = final.nur.repos.natsukium.hammerspoon.name;
          paths = [
            hammerspoon-cli
            final.nur.repos.natsukium.hammerspoon
          ];
        };
        EmmyLua_spoon = prev.stdenv.mkDerivation {
          name = "EmmyLua_spoon";
          src = prev.fetchFromGitHub {
            owner = "Hammerspoon";
            repo = "Spoons";
            rev = "5c20bcecc380acff5f0f5df7a718c5679aaaf62a";
            hash = "sha256-LeMsmm/au7GbnETVAUNNABanjU1byXpYbzWG/5nT4sM=";
          };
          installPhase = ''
            mkdir -p $out/share/Spoons
            cp -R $src/Source/EmmyLua.spoon/. $out/share/Spoons/EmmyLua.spoon
          '';
        };
      }
    )
  ];

  launchd.agents.hammerspoon = {
    enable = true;
    config = {
      Program = "${pkgs.hammerspoon}/Applications/Hammerspoon.app/Contents/MacOS/Hammerspoon";
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/hammerspoon.stdout";
      StandardErrorPath = "/tmp/hammerspoon.stderr";
    };
  };

  home.packages = with pkgs; [
    hammerspoon
  ];
  home.file.".hammerspoon" = {
    source = ./hammerspoon;
    recursive = true;
  };
  home.file.".hammerspoon/Spoons/EmmyLua.spoon" = {
    source = "${pkgs.EmmyLua_spoon}/share/Spoons/EmmyLua.spoon";
    recursive = true;
  };
}
