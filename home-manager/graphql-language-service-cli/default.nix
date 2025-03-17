{ pkgs, ... }:
let
  pname = "graphql-language-service-cli";
  version = "3.5.0";
in
{
  home.packages = [
    # This package is from https://github.com/graphql/graphiql
    # which is a monorepo managed with yarn.
    # I tried to build it with yarnConfigHook and friends,
    # but fix-yarn-lock complained that it cannot find yarn.lock even
    # I did provide one in postPatch.
    # I worked around by using buildNpmPackage instead.
    #
    # The original package.json lists graphql as a peer dependency.
    # But this is a CLI program so it does not really have any peer.
    # Therefore, I downloaded the tarball and edited it.
    # And then I run npm install to generate package-lock.json.
    # The edited package.json and generated package-lock.json are then
    # copied with postPatch.
    (pkgs.buildNpmPackage {
      inherit pname version;
      src = pkgs.fetchzip {
        url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
        hash = "sha256-wlb320GQalGh95AJTLvUwPGcYxdeet7t7JBhyFs1YBk=";
      };
      postPatch = ''
        cp ${./package.json} package.json
        cp ${./package-lock.json} package-lock.json
      '';
      dontNpmBuild = true;
      npmDepsHash = "sha256-Lqp+f+rbDW+rh/EOVpcqVGFrbYFF92jmzFvil34v3w8=";
    })
  ];
}
