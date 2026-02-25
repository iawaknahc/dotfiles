{ pkgs, config, ... }:
{
  home.packages = with pkgs; [ itsycal ];
  launchd.agents.itsycal = {
    enable = true;
    config = {
      # Itsycal says it must reside in the Applications directory.
      # So we cannot use the .app from /nix/store.
      # See https://mowglii.com/itsycal/appfolder
      Program = "${config.home.homeDirectory}/Applications/Home Manager Apps/Itsycal.app/Contents/MacOS/Itsycal";
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/itsycal.stdout";
      StandardErrorPath = "/tmp/itsycal.stderr";
    };
  };
}
