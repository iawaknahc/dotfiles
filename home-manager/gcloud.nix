{ pkgs, ... }:
{
  home.packages = [
    (pkgs.google-cloud-sdk.withExtraComponents (
      with pkgs.google-cloud-sdk.components;
      [
        gke-gcloud-auth-plugin
        gsutil
      ]
    ))
  ];
}
