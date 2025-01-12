{ pkgs, ... }:
{
  # cronstrue is a simple program to turn a cron expression into something human-readable.
  home.packages = [
    (pkgs.buildNpmPackage {
      pname = "cronstrue";
      version = "2.52.0";
      src = pkgs.fetchFromGitHub {
        owner = "bradymholt";
        repo = "cRonstrue";
        rev = "v2.52.0";
        hash = "sha256-4jTfgdopM8TEA1eke0p6Dtj9Jz1xvs0oVcXm2JYrRmc=";
      };
      npmDepsHash = "sha256-3IJaQm54e1zbbh4VHhz2YHfnq5VaVy9iWAelXZKo1/c=";
      npmBuildScript = "prepublishOnly";
      patches = [
        # Even I can set nativeBuildInputs = [ pkgs.git ];
        # to make git available to this derivation,
        # src is still not a git repository.
        # Running git add -A will error-out.
        # So we need to patch the build script to exclude that git command.
        (pkgs.writeText "cronstrue-build-patch" ''
          diff --git i/package.json w/package.json
          index 0002a89..a2cc19e 100644
          --- i/package.json
          +++ w/package.json
          @@ -67,7 +67,7 @@
               "start": "npm run build",
               "build": "npx tsc -p ./src --emitDeclarationOnly",
               "test": "npx mocha --reporter spec --require ts-node/register \"./test/**/*.ts\"",
          -    "prepublishOnly": "rm -rf ./dist && ./node_modules/webpack-cli/bin/cli.js && git add -A"
          +    "prepublishOnly": "rm -rf ./dist && ./node_modules/webpack-cli/bin/cli.js"
             },
             "dependencies": {}
           }
        '')
      ];
    })
  ];
}
