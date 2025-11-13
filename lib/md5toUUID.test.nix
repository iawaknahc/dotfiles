let
  md5toUUID = import ./md5toUUID.nix;
in
{
  testMD5ToUUID = {
    expr = md5toUUID "9811832a94e3c36bc5bbe3c682bb0bcb";
    expected = "9811832a-94e3-c36b-c5bb-e3c682bb0bcb";
  };
}
