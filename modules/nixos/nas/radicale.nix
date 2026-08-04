{
  pkgs,
  config,
  tailscaleIPv4,
  tailscaleFullDomain,
  ...
}:
{
  sops.secrets."radicale/username" = { };
  sops.secrets."radicale/password" = { };

  system.activationScripts."radicale-htpasswd" = {
    deps = [ "setupSecrets" ];
    text = ''
      mkdir -p /etc/radicale
      rm -f /etc/radicale/htpasswd
      username="$(cat ${config.sops.secrets."radicale/username".path})"
      cat ${
        config.sops.secrets."radicale/password".path
      } | ${pkgs.apacheHttpd}/bin/htpasswd -n -i -B -C 10 "$username" >> /etc/radicale/htpasswd
      chown -R ${config.services.radicale.user}:${config.services.radicale.group} /etc/radicale
    '';
  };

  # Restart Radicale daily to pick up renewed TLS certificate.
  systemd.services."restart-radicale" = {
    description = "Restart Radicale to pick up renewed TLS certificate";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
    };
    script = ''
      systemctl restart radicale.service
    '';
  };
  systemd.timers."restart-redicale" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  services.radicale.enable = true;
  services.radicale.user = "nixos";
  services.radicale.group = "users";
  services.radicale.settings = {
    server.hosts = [
      "127.0.0.1:5232"
      "${tailscaleIPv4}:5232"
    ];
    server.ssl = true;
    server.certificate = config.services.nginx.virtualHosts."${tailscaleFullDomain}".sslCertificate;
    server.key = config.services.nginx.virtualHosts."${tailscaleFullDomain}".sslCertificateKey;
    auth.type = "htpasswd";
    auth.htpasswd_filename = "/etc/radicale/htpasswd";
    auth.htpasswd_encryption = "autodetect";
    storage.filesystem_folder = "/data/syncthing/louischan/org/radicale-data";
  };
}
