{
  pkgs,
  lib,
  ...
}:
{
  system.stateVersion = "25.11";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  boot.initrd.availableKernelModules = [
    "xhci_pci" # USB 3.0 controller driver
    "nvme" # NVMe SSD driver
    "ahci" # AHCI driver
    "usb_storage" # USB storage driver
    "usbhid" # USB Human Interface Devices driver for keyboard
    "sd_mod" # SCSI driver
  ];
  boot.kernelModules = [ "kvm-intel" ];
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  swapDevices = [
    {
      label = "/dev/disk/by-label/swap";
    }
  ];
  fileSystems."/" = {
    label = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    label = "dev/disk/by-label/boot";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  time.timeZone = "Asia/Hong_Kong";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "nas";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  services.openssh.enable = true;
  services.tailscale.enable = true;

  security.sudo.wheelNeedsPassword = false;

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID10oX/o5t2FBc/DYIQMLqpmUYzFMiGebCtYCG0B1ik+ openpgp:0x5B63D933"
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Usage:
  #   nh os switch
  programs.nh.enable = true;
  programs.nh.flake = "/home/nixos/dotfiles";
}
