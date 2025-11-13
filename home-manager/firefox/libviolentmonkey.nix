{ lib }:
let
  parseMetadata = import ../../lib/userscript_metadata_block;
  md5ToUUID = import ../../lib/md5toUUID.nix;
in
rec {
  mkSettings = paths: lib.attrsets.mergeAttrsList (lib.lists.imap1 handleUserScript paths);

  handleUserScript =
    id: path:
    let
      fileContents = builtins.readFile path;
      md5 = builtins.hashFile "md5" path;
    in
    {
      "scr:${builtins.toString id}" = {
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
        meta = parseMetadata fileContents;
      };
      "code:${builtins.toString id}" = fileContents;
    };
}
