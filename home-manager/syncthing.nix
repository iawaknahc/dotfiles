{
  config,
  ...
}:
{
  services.syncthing.enable = true;

  # FIXME: It seems that the config I declare here is not applied to the service at all.

  sops.secrets."syncthing/devices/LouisChan16/id" = { };
  services.syncthing.settings.devices."LouisChan16" = {
    id = config.sops.placeholder."syncthing/devices/LouisChan16/id";
  };

  services.syncthing.settings.folders."~/personal/" = {
    id = "obsidian-personal";
    type = "sendonly";
    devices = [ "LouisChan16" ];
  };
}
