{
  ...
}:
{
  imports = [
    ./nix.nix
    ./system.nix
    # For unknown reason, I can no longer make /sys/class/leds/power appear
    # ./mod-led-ugreen.nix
    ./users.nix
    ./networking.nix
    ./git.nix
    ./vim.nix
    ./ssh.nix
    ./tailscale.nix
    ./zfs.nix
    ./mount.nix
    ./sops.nix
    ./smb.nix
    ./restic.nix
    ./syncthing.nix
  ];
}
