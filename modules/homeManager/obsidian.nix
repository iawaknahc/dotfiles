{ config, ... }:
{
  # The settings ARE NOT managed by Nix.
  # Obsidian stores settings in the vault.
  # The vault is configured to be synchronized between devices with Syncthing.
  programs.obsidian.enable = true;
  programs.obsidian.cli.enable = true;

  sops.secrets."obsidian/google_places_api_key" = { };
  sops.templates."obsidian-google-places-api-key.sh" = {
    mode = "0700";
    content = ''
      #!/bin/sh

      export GOOGLE_API_KEY="${config.sops.placeholder."obsidian/google_places_api_key"}"
    '';
  };
}
