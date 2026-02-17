{ lib, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  security.sudo.wheelNeedsPassword = false;

  time.timeZone = "Asia/Hong_Kong";
  i18n.defaultLocale = "en_US.UTF-8";

  boot.initrd.availableKernelModules = [
    "xhci_pci" # USB 3.0 controller driver
    "nvme" # NVMe SSD driver
    "ahci" # AHCI driver
    "usb_storage" # USB storage driver
    "usbhid" # USB Human Interface Devices driver for keyboard
    "sd_mod" # SCSI driver
  ];
  boot.kernelModules = [
    "kvm-intel"
  ];
}
