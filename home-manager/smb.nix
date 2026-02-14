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
      # Run as well as possible.
      RunAtLoad = true;
      # Run every minute.
      # We used to use PathState but it turned out that it does not work in the way we expected.
      StartCalendarInterval = { };
      # Since we run every minute, we want to suppress the logs to avoid housekeeping.
      StandardOutPath = "/dev/null";
      StandardErrorPath = "/dev/null";

      ProgramArguments = [
        # This service could fail for the following reasons:
        # - The service sops-nix has not yet finished, so this script does not even exist yet.
        # - Tailscale is not connected yet, so the host cannot be resolved.
        "${config.sops.templates."mount-smb.sh".path}"
      ];
    };
  };
}
