md5:
let
  length = builtins.stringLength md5;
in
if length != 32 then
  throw "MD5 hash must be exactly 32 hexadecimal characters, got ${length}"
else
  # Format as UUID: 8-4-4-4-12
  "${builtins.substring 0 8 md5}-${builtins.substring 8 4 md5}-${builtins.substring 12 4 md5}-${builtins.substring 16 4 md5}-${builtins.substring 20 12 md5}"
