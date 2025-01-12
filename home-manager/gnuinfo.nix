{ ... }:
{
  # GNU Info
  # The module sets home.extraOutputsToInstall so it is better to use it,
  # than to installing the package directly.
  programs.info.enable = true;

  home.file.".infokey" = {
    enable = true;
    source = ../.infokey;
  };
}
