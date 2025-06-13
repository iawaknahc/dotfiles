{
  pkgs,
  config,
  lib,
  ...
}:
let
  alfredSourceFile = lib.filterAttrs (key: value: value.enable) config.alfred.sourceFile;
  alfredStoreFile = lib.filterAttrs (key: value: value.enable) config.alfred.storeFile;
in
{
  options = {
    alfred.configDir = lib.mkOption {
      type = lib.types.str;
      description = ''
        The target path to the directory containing Alfred.alfredpreferences.
      '';
    };

    alfred.sourceDir = lib.mkOption {
      type = lib.types.str;
      description = ''
        The path to the source directory.
      '';
    };

    alfred.sourceFile = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { ... }:
          {
            options = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = ''
                  Whether the file should be generated.
                '';
              };
              source = lib.mkOption {
                type = lib.types.path;
                description = ''
                  The source path to the file.
                '';
              };
            };
          }
        )
      );
    };

    alfred.storeFile = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { ... }:
          {
            options = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = ''
                  Whether the file should be generated.
                '';
              };
              source = lib.mkOption {
                type = lib.types.path;
                description = ''
                  The source path to the file.
                '';
              };
            };
          }
        )
      );
    };
  };

  config = {
    home.activation.alfred = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      ''
        copyFile() {
          source="$1"
          target="$2"

          mkdir -p "$(dirname "$target")"
          if [ -d "$source" ]; then
            mkdir -p "$target"
            # Files from Nix store are usually read-only.
            # But we want to make them writable.
            ${pkgs.rsync}/bin/rsync --perms --chmod=Du+w,Fu+w --recursive "$source"/ "$target"
          else
            ${pkgs.rsync}/bin/rsync --perms --chmod=Du+w,Fu+w "$source" "$target"
          fi
        }
      ''
      + (lib.concatStrings (
        lib.mapAttrsToList (
          key: value:
          let
            sourcePath = value.source;
            sourceToString = toString sourcePath;
            sourceAbsolutePath =
              if lib.path.hasStorePathPrefix sourcePath then
                (
                  let
                    a = lib.strings.removePrefix builtins.storeDir sourceToString;
                    b = lib.strings.splitString "/" a;
                    c = lib.lists.drop 2 b;
                    d = lib.strings.concatStringsSep "/" c;
                    e = lib.strings.concatStringsSep "/" [
                      config.alfred.sourceDir
                      d
                    ];
                  in
                  toString e
                )
              else
                sourceToString;
            targetAbsolutePath = lib.strings.concatStringsSep "/" [
              config.alfred.configDir
              "Alfred.alfredpreferences"
              key
            ];
          in
          ''
            copyFile ${
              lib.escapeShellArgs [
                sourceAbsolutePath
                targetAbsolutePath
              ]
            }
          ''
        ) alfredSourceFile
      ))
      + (lib.concatStrings (
        lib.mapAttrsToList (
          key: value:
          let
            targetAbsolutePath = lib.strings.concatStringsSep "/" [
              config.alfred.configDir
              "Alfred.alfredpreferences"
              key
            ];
          in
          ''
            copyFile ${
              lib.escapeShellArgs [
                (toString value.source)
                targetAbsolutePath
              ]
            }
          ''
        ) alfredStoreFile
      ))
    );
  };
}
