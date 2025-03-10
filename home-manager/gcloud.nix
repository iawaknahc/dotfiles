{ pkgs, ... }:
{
  home.packages = [
    pkgs.docker-credential-gcr
    (pkgs.google-cloud-sdk.withExtraComponents (
      with pkgs.google-cloud-sdk.components;
      [
        gke-gcloud-auth-plugin
        gsutil
      ]
    ))
  ];
}
