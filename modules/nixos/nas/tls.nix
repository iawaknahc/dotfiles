{ ... }:
{
  sops.secrets."ca/private_key_pem" = {
    path = "/run/secrets/ca-key.pem";
  };
  sops.secrets."ca/certificate_pem" = {
    path = "/run/secrets/ca-certificate.pem";
  };
}
