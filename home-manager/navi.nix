{ pkgs, ... }:
{
  home.packages = [ pkgs.navi ];

  # navi is known to write log files to XDG_CONFIG_HOME
  # See https://github.com/denisidoro/navi/blob/master/docs/navi_config.md#logging
  xdg.configFile."navi" = {
    enable = true;
    recursive = true;
    source = ../.config/navi;
  };

  home.file.".local/share/navi/cheats" = {
    enable = true;
    recursive = true;
    source = ../.local/share/navi/cheats;
  };
}
