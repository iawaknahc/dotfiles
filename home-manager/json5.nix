{ pkgs, ... }:
let
  pname = "json5";
  version = "2.2.3";
  packageLockJSON = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/${pname}/${pname}/refs/tags/v${version}/package-lock.json";
    hash = "sha256-MbQRaW2VxXqpeWK95RG7n0j9cv/j/frlxbGm6HL96wU=";
  };
in
{
  home.packages = [
    # As of 2024-12-23, there is no official json5 package.
    # So let's build it ourselves.
    # The gist of this approach is
    # 1. Use pkgs.fetchzip to fetch from NPM registry, instead of fetching the source tree.
    #    The tarball from NPM registry is the built artifact, thus we can specify dontNpmBuild=true.
    # 2. By definition, package-lock.json cannot be published, so it does not appear in the tarball.
    #    See https://docs.npmjs.com/cli/v11/configuring-npm/package-lock-json#package-lockjson-vs-npm-shrinkwrapjson
    #    So we need to fetch it from the source tree.
    (pkgs.buildNpmPackage {
      inherit pname version;
      src = pkgs.fetchzip {
        url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
        hash = "sha256-fd/IKAbZn9P6pZDVoCd0ltapUy5duUpErs4dZISeItI=";
      };
      postPatch = ''
        cp ${packageLockJSON} package-lock.json
      '';
      dontNpmBuild = true;
      npmDepsHash = "sha256-ZGOo77uph5JeRGUB0c+BZOg04hXnvpXM95zx4ByX2E4=";
    })
  ];
}
