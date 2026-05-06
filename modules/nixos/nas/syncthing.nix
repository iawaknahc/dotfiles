{ pkgs, ... }:
{
  services.syncthing.enable = true;
  services.syncthing.user = "nixos";
  services.syncthing.group = "users";
  services.syncthing.dataDir = "/home/nixos/syncthing";
  services.syncthing.overrideDevices = true;
  services.syncthing.overrideFolders = true;
  services.syncthing.openDefaultPorts = true;
  services.syncthing.settings.devices."LouisChan16" = {
    id = "DZH4SZM-YXPC5JN-3KCTXKQ-MRCJ5QM-STPPXNN-ZY55RQG-YRIUWHV-NBXKNQ5";
    addresses = [
      "tcp://louischan-16-pro.tail78d407.ts.net:22000"
    ];
  };
  services.syncthing.settings.devices."louischan-m4" = {
    id = "BA72RDZ-AWAG46I-KWWRSPX-XHQC5OH-J2ZMHBU-LDUMBQU-TWUDZ6M-4XGGUQJ";
    addresses = [
      "tcp://louischan-m4.tail78d407.ts.net:22000"
    ];
  };
  services.syncthing.settings.folders."/data/louischan/obsidian/vaults/personal/" = {
    id = "obsidian-personal";
    type = "sendreceive";
    devices = [
      "LouisChan16"
      "louischan-m4"
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
  environment.systemPackages = with pkgs; [
    syncthing
  ];
}
