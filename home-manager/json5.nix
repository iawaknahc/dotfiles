{ pkgs, ... }:
{
  home.packages = [
    # As of 2024-12-23, there is no official json5 package.
    # So let's build it ourselves.
    (pkgs.buildNpmPackage {
      pname = "json5";
      version = "2.2.3";
      src = pkgs.fetchFromGitHub {
        owner = "json5";
        repo = "json5";
        rev = "v2.2.3";
        hash = "sha256-ZOF1aLzs4AREy0PgPWexBYB5rL81UOVRPDcnSBOghiE=";
      };
      npmDepsHash = "sha256-ZGOo77uph5JeRGUB0c+BZOg04hXnvpXM95zx4ByX2E4=";
    })
  ];
}
