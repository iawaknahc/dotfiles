{
  ...
}:
{
  services.syncthing.enable = true;
  services.syncthing.overrideDevices = true;
  services.syncthing.overrideFolders = true;

  # It is impossible to use secrets at evaluation time of nix code.
  # https://github.com/Mic92/sops-nix?tab=readme-ov-file#using-secrets-at-evaluation-time
  services.syncthing.settings.devices."nas" = {
    id = "AS5FKVU-YOJNR3P-FRSEUYG-BOY47VC-UB2ZJYK-EBJYV56-GEJCVAP-ABNHOAD";
    addresses = [
      "tcp://nas.tail78d407.ts.net:22000"
    ];
  };
  services.syncthing.settings.devices."LouisChan16" = {
    id = "DZH4SZM-YXPC5JN-3KCTXKQ-MRCJ5QM-STPPXNN-ZY55RQG-YRIUWHV-NBXKNQ5";
    addresses = [
      "tcp://louischan-16-pro.tail78d407.ts.net:22000"
    ];
  };

  # This folder is assumed to contain a file ".stignore" at the root.
  # The content of .stignore should be
  # .obsidian
  services.syncthing.settings.folders."~/personal/" = {
    id = "obsidian-personal";
    type = "sendreceive";
    devices = [
      "nas"
      "LouisChan16"
    ];
  };

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
