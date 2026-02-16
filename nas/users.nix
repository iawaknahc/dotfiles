{ ... }:
{
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
}
