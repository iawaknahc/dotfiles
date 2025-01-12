{ pkgs, ... }:
{
  home.packages = [
    # qrencode generates QR code locally.
    pkgs.qrencode
    # zbar offers an executable zbarimg to read QR code locally.
    pkgs.zbar
  ];
}
