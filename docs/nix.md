## Hello, World

```
$ nix eval --raw --expr '"Hello, World\n"'
Hello, World
```

## Explore Nix in a REPL

```
$ nix repl
```

## Inspect the contents of NIX_PATH

```
$ echo $NIX_PATH
```

## Inspect nixpkgs

```
$ nix repl --file '<nixpkgs>'
```

## Build a derivation

```
$ mkdir mydrv
$ cd mydrv
$ nix flake init -t templates#utils-generic

$ cat flake.nix
{
  inputs = {
    utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      utils,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        package =
          { buildNpmPackage, fetchFromGitHub }:
          buildNpmPackage {
            pname = "json5";
            version = "2.2.3";
            src = fetchFromGitHub {
              owner = "json5";
              repo = "json5";
              rev = "v2.2.3";
              hash = "sha256-ZOF1aLzs4AREy0PgPWexBYB5rL81UOVRPDcnSBOghiE=";
            };
            npmDepsHash = "sha256-ZGOo77uph5JeRGUB0c+BZOg04hXnvpXM95zx4ByX2E4=";
          };
      in
      {
        packages.default = (pkgs.callPackage package { });
      }
    );
}

$ nix build
$ result/bin/json5 --help

  Usage: json5 [options] <file>

  If <file> is not provided, then STDIN is used.

  Options:

    -s, --space              The number of spaces to indent or 't' for tabs
    -o, --out-file [file]    Output to the specified file, otherwise STDOUT
    -v, --validate           Validate JSON5 but do not output JSON
    -V, --version            Output the version number
    -h, --help               Output usage information
```

## Prepare a shell that would be used to build a derivation

```
# Assume ./flake.nix has outputs.package.<system>.default
$ nix develop
```

## Prepare a shell that has some packages available

```
$ mkdir myenv
$ cd myenv
$ nix flake init -t templates#utils-generic

$ cat flake.nix
{
  inputs = {
    utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      utils,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShell = pkgs.mkShell {
          packages = [ pkgs.ponysay ];
        };
      }
    );
}

# Replace the default bash shell with $SHELL
$ nix develop -c "exec $SHELL"
```
