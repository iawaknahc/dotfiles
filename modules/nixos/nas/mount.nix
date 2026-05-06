{ ... }:
{
  swapDevices = [
    {
      device = "/dev/disk/by-label/swap";
    }
  ];
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };
  fileSystems."/data" = {
    # This has to be a pool name, not an absolute path.
    device = "data";
    fsType = "zfs";
  };
}
