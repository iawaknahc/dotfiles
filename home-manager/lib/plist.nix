{
  pkgs,
  ...
}:
let
  json2plist = pkgs.writeText "json2plist.py" ''
    import json
    import plistlib
    import sys

    with open(sys.argv[1]) as f:
      v = json.load(f)

    print(plistlib.dumps(v).decode(), end="")
  '';
in
rec {
  dict = pairs: {
    pairs = pairs;
  };
  _toJSON =
    rec {
      f =
        jsonValue:
        if builtins.isInt jsonValue then
          builtins.toJSON jsonValue
        else if builtins.isFloat jsonValue then
          builtins.toJSON jsonValue
        else if builtins.isBool jsonValue then
          builtins.toJSON jsonValue
        else if builtins.isString jsonValue then
          builtins.toJSON jsonValue
        else if jsonValue == builtins.null then
          builtins.toJSON builtins.null
        else if builtins.isList jsonValue then
          let
            a = builtins.map (listValue: f listValue) jsonValue;
            b = builtins.concatStringsSep "," a;
          in
          "[${b}]"
        else if builtins.isAttrs jsonValue then
          let
            pairs = jsonValue.pairs;
            a = builtins.map (
              pair:
              if builtins.isString pair.key then
                "${f pair.key}:${f pair.value}"
              else
                throw "JSON: dict key is not string: ${builtins.toString pair.key}"
            ) pairs;
            b = builtins.concatStringsSep "," a;
          in
          "{${b}}"
        else
          throw "JSON: unsupported data type: ${builtins.toString jsonValue}";
    }
    .f;
  toPlist =
    value:
    let
      jsonTextFile = pkgs.writeText "json" (_toJSON value);
      plistFile = pkgs.runCommand "plist" { } ''
        ${pkgs.python3}/bin/python3 ${json2plist} ${jsonTextFile} > $out
      '';
    in
    plistFile;
}
