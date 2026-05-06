{ pkgs, ... }:
{
  home.packages =
    if pkgs.stdenv.hostPlatform.isDarwin then
      [
        (pkgs.writeShellScriptBin "tailscale" ''
          /Applications/Tailscale.app/Contents/MacOS/Tailscale "$@"
        '')
      ]
    else
      [ ];
}
