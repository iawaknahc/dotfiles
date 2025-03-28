{ pkgs, ... }:
let
  pname = "json5";
  version = "2.2.3";
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
      dontNpmBuild = true;

      # On 2025-03-18, when I update flake.lock to the latest version on that day.
      # This package started failing to build.
      # The error is noBrokenSymlinks.
      # Those symlinks are in node_modules/.bin which are the binary of devDependencies.
      # For some unknown reason, the devDependencies were pruned, but the symlinks were left over.
      # Those broken symlinks made nix unhappy because it by default check broken symlinks.
      # To work around this, I patched package.json so that there is no devDependencies.
      # So there were no node_modules/.bin in the first place.
      # But another problem arose.
      # Since the package has no dependencies,
      # npm install does not creat node_modules.
      # The install script of buildNpmPackage expects node_modules to be present.
      # So we create it in preInstall.
      # buildNpmPackage expects node_modules not to be empty.
      # Set forceEmptyCache=true to tell buildNpmPackage node_modules is intentionally empty.
      patches = [ ./package.json.patch ];
      postPatch = ''
        cp ${./package-lock.json} package-lock.json
      '';
      preInstall = ''
        mkdir node_modules
      '';
      npmDepsHash = "sha256-k39u9wfY5qzwfIGbk2betjHZ2EkGIJuYp02iIY9mRlg=";
      forceEmptyCache = true;
    })
  ];
}
