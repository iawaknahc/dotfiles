{
  pkgs,
  config,
  lib,
  ...
}:
{
  # I am aware that there is programs.rclone.*
  # But its rclone.conf generation supports systemd only, so it is not really usable on macOS.
  # So in here, we make use of sops.templates to generate rclone.conf,
  # and a very simple activation to make a symlink.
  # See https://github.com/nix-community/home-manager/blob/release-25.11/modules/programs/rclone.nix#L399
  home.packages = with pkgs; [ rclone ];

  # Use SOPS to generate ~/.config/rclone/rclone.conf from ../secrets/secrets.yaml
  sops.secrets."rclone/remotes/sandisk/host" = { };
  sops.secrets."rclone/remotes/sandisk/pass" = { };
  sops.secrets."rclone/remotes/googledrive/client_id" = { };
  sops.secrets."rclone/remotes/googledrive/client_secret" = { };
  sops.secrets."rclone/remotes/googledrive/token" = { };
  sops.templates."rclone.conf".content = ''
    [sandisk]
    type = smb
    host = ${config.sops.placeholder."rclone/remotes/sandisk/host"}
    pass = ${config.sops.placeholder."rclone/remotes/sandisk/pass"}

    [googledrive]
    type = drive
    client_id = ${config.sops.placeholder."rclone/remotes/googledrive/client_id"}
    client_secret = ${config.sops.placeholder."rclone/remotes/googledrive/client_secret"}
    scope = drive
    token = ${config.sops.placeholder."rclone/remotes/googledrive/token"}
    team_drive = 
  '';
  # Use a simple activation script to work around impurity.
  home.activation.rcloneconfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -f ${config.xdg.configHome}/rclone/rclone.conf
    mkdir -p ${config.xdg.configHome}/rclone
    ln -s ${config.sops.templates."rclone.conf".path} ${config.xdg.configHome}/rclone/rclone.conf
  '';
}
