{ pkgs, config, ... }:
{
  sops.secrets."obsidian/google_places_api_key" = { };
  sops.templates."obsidian-google-places-api-key.sh" = {
    mode = "0700";
    content = ''
      #!/bin/sh

      export GOOGLE_API_KEY="${config.sops.placeholder."obsidian/google_places_api_key"}"
    '';
  };

  home.packages =
    if pkgs.stdenv.hostPlatform.isDarwin then
      [
        (pkgs.writeShellScriptBin "obsidian" ''
          /Applications/Obsidian.app/Contents/MacOS/obsidian-cli "$@"
        '')
      ]
    else
      [ ];
}
