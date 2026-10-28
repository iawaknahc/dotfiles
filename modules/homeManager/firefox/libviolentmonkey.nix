{ pkgs, lib }:
let
  parseMetadata = import ../../../lib/userscript_metadata_block;
  md5ToUUID = import ../../../lib/md5toUUID.nix;
in
rec {
  mkSettings = paths: lib.attrsets.mergeAttrsList (lib.lists.imap1 handleUserScript paths);

  # An attrset from url to the script content.
  knownRequires = builtins.listToAttrs (
    lib.lists.map
      ({ url, hash }: {
        name = url;
        value = builtins.readFile "${pkgs.fetchurl {
          inherit url hash;
        }}";
      })
      [
        {
          url = "https://cdn.jsdelivr.net/npm/@violentmonkey/shortcut@1.4.4";
          hash = "sha256-0DKg6uKUp7GDESn/64JOuK6dmrQ6UH/Xb1Avqj7yfR8=";
        }
        {
          url = "https://cdn.jsdelivr.net/npm/@violentmonkey/dom@2.2.1";
          hash = "sha256-k+J/BEFgvIeV87y/AO2DNebmEPVaaFMCIklXQgLt+NY=";
        }
        {
          url = "https://cdn.jsdelivr.net/npm/@violentmonkey/ui@0.7.9";
          hash = "sha256-rJwiQ6gZKGoZ1AkLrNK0CptbqUejaKDsccORrdDvApc=";
        }
      ]
  );

  handleUserScript =
    id: path:
    let
      fileContents = builtins.readFile path;
      md5 = builtins.hashFile "md5" path;
      meta = parseMetadata fileContents;
    in
    {
      "scr:${builtins.toString id}" = {
        inherit meta;
        custom = {
          origInclude = true;
          origExclude = true;
          origMatch = true;
          origExcludeMatch = true;
          pathMap = { };
        };
        config = {
          enabled = 1;
          shouldUpdate = 0;
          removed = 0;
        };
        props = {
          inherit id;
          position = id;
          lastModified = 0;
          lastUpdate = 0;
          uuid = md5ToUUID md5;
        };
      };
      "code:${builtins.toString id}" = fileContents;
    }
    // (builtins.listToAttrs (
      lib.lists.map (url: {
        name = "req:${url}";
        value = knownRequires."${url}";
      }) (meta.require or [ ])
    ));
}
