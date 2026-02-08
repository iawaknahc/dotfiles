{ config, ... }:
{
  sops.secrets."smb/host" = { };
  sops.secrets."smb/password" = { };
  sops.secrets."smb/username" = { };

  sops.templates."mount-smb.sh" = {
    mode = "0700";
    content = ''
      #!/bin/sh

      set -e

      mkdir -p ${config.home.homeDirectory}/Volumes/ssd

      mount -t smbfs //${config.sops.placeholder."smb/username"}:${
        config.sops.placeholder."smb/password"
      }@${config.sops.placeholder."smb/host"}/ssd ${config.home.homeDirectory}/Volumes/ssd

      printf "mounted at %s\n" "$(date -Iseconds)"
    '';
  };

  launchd.agents.mount-smb = {
    enable = true;
    config = {
      KeepAlive = {
        # This means KeepAlive as long as the exit code is non-zero (i.e. crashed for whatever reason).
        SuccessfulExit = false;
        PathState = {
          # This means KeepAlive as long as this path does not exist (i.e. the drive is not mounted).
          "${config.home.homeDirectory}/Volumes/ssd/louischan" = false;
        };
      };
      ThrottleInterval = 10;
      RunAtLoad = true;
      ProgramArguments = [
        # This service could fail for the following reasons:
        # - The service sops-nix has not yet finished, so this script does not even exist yet.
        # - Tailscale is not connected yet, so the host cannot be resolved.
        "${config.sops.templates."mount-smb.sh".path}"
      ];
      StandardOutPath = "/tmp/mount-smb.stdout";
      StandardErrorPath = "/tmp/mount-smb.stderr";
    };
  };
}
