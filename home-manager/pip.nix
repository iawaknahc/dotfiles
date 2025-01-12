{ ... }:
{
  xdg.configFile."pip" = {
    enable = true;
    recursive = true;
    source = ../.config/pip;
  };
}
