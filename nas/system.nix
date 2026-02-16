{ lib, config, ... }:
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

  # Taken from https://nixos.wiki/wiki/Linux_kernel#Out-of-tree_kernel_modules
  boot.extraModulePackages = [
    (config.boot.kernelPackages.callPackage (
      {
        stdenv,
        fetchFromGitHub,
        kernel,
      }:
      stdenv.mkDerivation {
        pname = "led-ugreen";
        version = "0.3";
        src = fetchFromGitHub {
          owner = "miskcoo";
          repo = "ugreen_leds_controller";
          rev = "v0.3";
          hash = "sha256-IY8b9Hc2t/Zcz4TlQ5p+D/Q/ilE9S308DIZFuJh/isE=";
        };
        sourceRoot = "source/kmod";
        hardeningDisable = [
          "pic"
          "format"
        ];
        nativeBuildInputs = kernel.moduleBuildDependencies;
        makeFlags = [
          "KERNELRELEASE=${kernel.modDirVersion}"
          "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
          "INSTALL_MOD_PATH=$(out)"
        ];
      }
    ) { })
  ];
  boot.kernelModules = [
    "kvm-intel"

    # https://github.com/miskcoo/ugreen_leds_controller/tree/v0.3?tab=readme-ov-file#the-kernel-module
    # led-ugreen requires i2c-dev to work
    # led-ugreen is built above.
    "i2c-dev"
    "led-ugreen"
  ];

  # According to https://github.com/miskcoo/ugreen_leds_controller/tree/v0.3?tab=readme-ov-file#the-kernel-module
  # It is required to register the device on every boot.
  # This service is taken from https://github.com/miskcoo/ugreen_leds_controller/blob/v0.3/scripts/systemd/ugreen-probe-leds.service
  # and the script https://github.com/miskcoo/ugreen_leds_controller/blob/v0.3/scripts/ugreen-probe-leds
  # and then simplified into a oneliner.
  # I have tried different approaches but it is very stable on every reboot.
  # Sometimes, after reboot /sys/class/leds do not contain the expected files.
  #
  # systemd.services.ugreen-probe-leds = {
  #   wantedBy = [ "multi-user.target" ];
  #   # For some unknown reason, after systemd-modules-load.service does not work.
  #   after = [ "multi-user.target" ];
  #   requires = [ "systemd-modules-load.service" ];
  #   preStart = ''
  #     sleep 5
  #   '';
  #   script = ''
  #     echo "led-ugreen 0x3a" > /sys/bus/i2c/devices/i2c-0/new_device
  #   '';
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     StandardOutput = "journal";
  #   };
  # };
}
