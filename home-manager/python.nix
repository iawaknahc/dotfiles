{
  pkgs,
  ...
}:
let
  # python3 is usually one version behind.
  version = "313";
in
{
  home.packages = [
    pkgs."python${version}"
    pkgs."python${version}Packages".json5
  ];
}
