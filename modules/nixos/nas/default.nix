{
  ...
}:
{
  config = {
    # See https://emudhra.we-have-a-problem.com/
    security.pki.caCertificateBlacklist = [
      "Comodo AAA Services root"
      "emSign ECC Root CA - G3"
    ];
  };

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
    ./tls.nix
    ./radicale.nix
    ./blocky.nix
  ];
}
