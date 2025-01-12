{ pkgs, ... }:
{
  home.packages = builtins.map (
    path:
    let
      basename = builtins.baseNameOf (builtins.toString path);
      text = builtins.readFile path;
    in
    (pkgs.writeScriptBin basename text)
  ) (pkgs.lib.fileset.toList (pkgs.lib.fileset.maybeMissing ../.local/bin));
}
