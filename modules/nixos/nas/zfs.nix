{ ... }:
{
  # Enable ZFS
  boot.supportedFilesystems = [ "zfs" ];
  # The doc says it should be set to false.
  # https://search.nixos.org/options?channel=25.11&query=boot.zfs&show=boot.zfs.forceImportRoot
  boot.zfs.forceImportRoot = false;
  # The doc says ZFS requires this.
  # https://search.nixos.org/options?channel=25.11&query=ZFS&show=networking.hostId
  # This was generated with `head -c 8 /etc/machine-id`
  networking.hostId = "0c1b9b5d";
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "weekly";
}
