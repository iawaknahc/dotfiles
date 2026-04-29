{ pkgs, ... }:
{
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
