{ pkgs, config, ... }:
{
  sops.secrets."rclone/remotes/googledrive/client_id" = { };
  sops.secrets."rclone/remotes/googledrive/client_secret" = { };
  sops.secrets."rclone/remotes/googledrive/token" = { };
  sops.secrets."nas_samba/password" = { };
  sops.templates."rclone.conf".content = ''
    [googledrive]
    type = drive
    client_id = ${config.sops.placeholder."rclone/remotes/googledrive/client_id"}
    client_secret = ${config.sops.placeholder."rclone/remotes/googledrive/client_secret"}
    scope = drive
    token = ${config.sops.placeholder."rclone/remotes/googledrive/token"}
    team_drive =
  '';
  services.restic.backups.data = {
    rcloneConfigFile = "/run/secrets/rendered/rclone.conf";
    repository = "rclone:googledrive:restic";
    passwordFile = "/run/secrets/nas_samba/password";
    initialize = true;
    paths = [
      "/data"
    ];
    pruneOpts = [
      "--keep-within 2y"
      "--keep-within-hourly 24h"
      "--keep-within-daily 7d"
      "--keep-within-weekly 28d"
      "--keep-within-monthly 3m"
      "--keep-within-yearly 1y"
    ];
    timerConfig = {
      Persistent = true;
      OnCalendar = "hourly";
      RandomizedDelaySec = 300;
    };
  };
  environment.systemPackages = with pkgs; [
    restic
  ];
}
