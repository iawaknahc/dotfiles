{ ... }:
{
  services.samba.enable = true;
  services.samba.openFirewall = true;
  services.samba.settings.global.security = "user";
  services.samba.settings.nas_samba = {
    path = "/data";
    browsable = "yes";
    public = "no";
    writeable = "yes";
    "valid users" = "nixos";
    "create mask" = "0666";
    "directory mask" = "0777";
  };
}
