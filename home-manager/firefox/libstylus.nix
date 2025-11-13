{ lib }:
let
  md5ToUUID = import ../../lib/md5toUUID.nix;
in
rec {
  mkSettings =
    paths:
    lib.attrsets.mergeAttrsList (
      [
        {
          dbInChromeStorage = true;
        }
      ]
      ++ (lib.lists.imap1 (id: path: {
        "style-${builtins.toString id}" = mkStylus { inherit id path; };
      }) paths)
    );

  mkStylus =
    { id, path }:
    let
      name = builtins.baseNameOf path;
      code = builtins.readFile path;
      md5 = builtins.hashFile "md5" path;
    in
    {
      inherit id name;
      enabled = true;
      installDate = 0;
      updateDate = 0;
      _rev = 0;
      _id = md5ToUUID md5;
      sections = [
        {
          code = ''
            /* Managed by Nix. DO NOT MODIFY! */
            ${code}
          '';
        }
      ];
    };
}
