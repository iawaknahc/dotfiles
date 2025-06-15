{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      hs = prev.stdenv.mkDerivation {
        name = "hs";
        pname = "hs";

        # We have made a compromise here.
        #
        # We cannot references /Applications/Hammerspoon.app because
        # - It is considered as impure by Nix.
        # - In case /Applications/Hammerspoon.app is not installed, the build will fail.
        #
        # So we write a shell wrapper at ./hs
        #
        # For the manpage, it is less harmful to have an outdated one.
        # So I copied the one I found inside /Applications/Hammerspoon.app as of the time of writing.
        src = ./.;

        installPhase = ''
          find .
          mkdir -p $out

          mkdir -p $out/bin
          cp ./hs $out/bin/

          mkdir -p $out/share/man/man1
          cp ./hs.1 $out/share/man/man1/
        '';
      };
    })
  ];

  home.packages = with pkgs; [
    hs
  ];
  home.file.".hammerspoon" = {
    source = ../../.hammerspoon;
    recursive = true;
  };
}
