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
    source = ../../.hammerspoon;
    recursive = true;
  };
}
