{
  ...
}:
{
  services.syncthing.enable = true;
  services.syncthing.overrideDevices = true;
  services.syncthing.overrideFolders = true;

  # It is impossible to use secrets at evaluation time of nix code.
  # https://github.com/Mic92/sops-nix?tab=readme-ov-file#using-secrets-at-evaluation-time
  services.syncthing.settings.devices."LouisChan16" = {
    id = "DZH4SZM-YXPC5JN-3KCTXKQ-MRCJ5QM-STPPXNN-ZY55RQG-YRIUWHV-NBXKNQ5";
  };

  services.syncthing.settings.folders."~/personal/" = {
    id = "obsidian-personal";
    type = "sendonly";
    devices = [ "LouisChan16" ];
  };

  # According to https://github.com/nix-community/home-manager/blob/master/modules/services/syncthing.nix
  # ~/Library/Application Support/Syncthing/config.xml IS NOT modified at all.
  # Instead, the config is modified via the JSON REST API.
  # However, according to my observation, I need to manually restart Syncthing in the GUI to apply the configuration.
  # FIXME: Actually this is a bug https://github.com/nix-community/home-manager/issues/6542
  # There is a PR too https://github.com/nix-community/home-manager/pull/8415
  services.syncthing.settings.options = {
    listenAddresses = [ "tcp://0.0.0.0:22000" ];

    globalAnnounceServers = [ ];
    stunServers = [ ];
    urURL = "https://0.0.0.0";
    releasesURL = "https://0.0.0.0";
    crURL = "https://0.0.0.0";

    globalAnnounceEnabled = false;
    localAnnounceEnabled = false;
    crashReportingEnabled = false;
    relaysEnabled = false;
    natEnabled = false;
    announceLANAddresses = false;
    startBrowser = false;
    urAccepted = -1;

    autoUpgradeIntervalH = 0;
  };
}
