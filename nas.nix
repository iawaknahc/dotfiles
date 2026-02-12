{
  pkgs,
  ...
}:
{
  imports = [
    ./nas-hardware-configuration.nix
  ];

  system.stateVersion = "25.11";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Asia/Hong_Kong";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  services.openssh.enable = true;

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1IZDI1NTE5AAAAID10oX/o5t2FBc/DYIQMLqpmUYzFMiGebCtYCG0B1ik+ openpgp:0x5B63D933"
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    git
  ];
}
