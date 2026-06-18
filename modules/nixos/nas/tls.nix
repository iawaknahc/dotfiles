{ pkgs, config, ... }:
let
  domain = "nas.tail78d407.ts.net";
in
{
  sops.secrets."ca/private_key_pem" = {
    path = "/run/secrets/ca-key.pem";
  };
  sops.secrets."ca/certificate_pem" = {
    path = "/run/secrets/ca-certificate.pem";
  };

  systemd.services."generate-tls-certificate" = {
    description = "Generate TLS certificate for this host";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
      Group = "root";
    };
    script =
      let
        pathKey = builtins.toString config.services.nginx.virtualHosts."${domain}".sslCertificateKey;
        pathCert = builtins.toString config.services.nginx.virtualHosts."${domain}".sslCertificate;
        days = "30";
      in
      ''
        set -euo pipefail

        CERT_DIR="$(dirname ${pathCert})"
        mkdir -p "$CERT_DIR"

        ${pkgs.openssl}/bin/openssl genpkey -algorithm EC -out ${pathKey} -outpubkey /dev/null -pkeyopt ec_paramgen_curve:P-256
        chmod 640 ${pathKey}
        chown root:nginx ${pathKey}

        ${pkgs.openssl}/bin/openssl req -x509 -CA ${config.sops.secrets."ca/certificate_pem".path} -CAkey ${
          config.sops.secrets."ca/private_key_pem".path
        } -key ${pathKey} -subj "/CN=tls" -addext "basicConstraints=critical,CA:FALSE" -addext "keyUsage=critical, digitalSignature" -addext "extendedKeyUsage=critical, serverAuth, clientAuth" -addext "subjectAltName=critical, DNS:${domain}" -days ${days} -out ${pathCert}
        chmod 644 ${pathCert}
        chown root:nginx ${pathCert}

        systemctl reload nginx
      '';
  };

  systemd.timers."generate-tls-certificate" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  services.nginx.enable = true;
  services.nginx.enableReload = true;
  services.nginx.recommendedTlsSettings = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.recommendedBrotliSettings = true;
  services.nginx.recommendedGzipSettings = true;
  services.nginx.recommendedProxySettings = true;
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    sslCertificate = "/etc/nginx/tls-certificate.pem";
    sslCertificateKey = "/etc/nginx/tls-key.pem";
    locations."/" = {
      return = "200 '<html><body>It works</body></html>'";
      extraConfig = ''
        default_type text/html;
      '';
    };
  };
}
