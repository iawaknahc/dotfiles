{ config, ... }:
{
  programs.tealdeer.enable = true;
  programs.tealdeer.settings.display.compact = false;
  programs.tealdeer.settings.display.show_title = true;
  programs.tealdeer.settings.search.languages = [ "en" ];
  programs.tealdeer.settings.updates.auto_update = true;
  programs.tealdeer.settings.updates.auto_update_interval_hours = 24;
  programs.tealdeer.settings.directories.custom_pages_dir = "${config.xdg.configHome}/tealdeer/pages";

  xdg.configFile."tealdeer/pages" = {
    recursive = true;
    source = ../.config/tealdeer/pages;
  };
}
