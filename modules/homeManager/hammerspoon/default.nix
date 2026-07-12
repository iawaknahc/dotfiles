{ pkgs, ... }:
{
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
    recursive = true; # This has to be recursive because this spoon writes to its own directory.
  };
}
