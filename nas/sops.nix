{ pkgs, ... }:
{
  # sops by default use SSH key to decrypt if services.openssh.enable = true.
  # So we only need to run `sops updatekeys path/to/secret` on a machine that can decrypt the file.
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  environment.systemPackages = with pkgs; [
    sops
  ];
}
