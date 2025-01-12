{ ... }:
{
  xdg.configFile."ghostty/config" = {
    enable = true;
    source = ../.config/ghostty/config;
  };
}
