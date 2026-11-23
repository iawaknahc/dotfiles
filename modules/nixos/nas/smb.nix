{ ... }:
{
  services.samba.enable = true;
  services.samba.openFirewall = true;
  services.samba.settings.global.security = "user";

  # When the macOS SMB client connects, it leaves many ._ files.
  # We want to stop it.
  # See https://man.archlinux.org/man/vfs_catia.8.en
  # See https://man.archlinux.org/man/vfs_fruit.8.en
  # See https://man.archlinux.org/man/vfs_streams_xattr.8.en
  services.samba.settings.global."vfs objects" = "catia fruit streams_xattr";
  # The default is file, which means store the resource fork in a ._ AppleDouble file
  # This is the behavior we want to eliminate.
  services.samba.settings.global."fruit:resource" = "xattr";
  # This means pass the metadata to the next module, which is streams_xattr.
  services.samba.settings.global."fruit:metadata" = "stream";

  services.samba.settings.nas_samba = {
    path = "/data/smb";
    browsable = "yes";
    public = "no";
    writable = "yes";
    "valid users" = "nixos";
    "create mask" = "0666";
    "directory mask" = "0777";
  };
}
