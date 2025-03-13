{ pkgs, ... }:
let
  version = "2.56.0";
  pname = "cronstrue";
  packageLockJSON = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/bradymholt/${pname}/refs/tags/v${version}/package-lock.json";
    hash = "sha256-arslilvaFS7De77BUqbEeE5mb+snls5bbDQKMaei6SM=";
  };
in
{
  # cronstrue is a simple program to turn a cron expression into something human-readable.
  home.packages = [
    (pkgs.buildNpmPackage {
      inherit pname version;
      src = pkgs.fetchzip {
        url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
        hash = "sha256-xOk+BXbbFM7J9z+YddsFzduVGMjtcaKcMKZejCCQjmU=";
      };
      postPatch = ''
        cp ${packageLockJSON} package-lock.json
      '';
      npmDepsHash = "sha256-S7Qj89CuteMTvwU5DN+byY9G5gXTt505D+VVq8CqkoQ=";
      dontNpmBuild = true;
    })
  ];
}
