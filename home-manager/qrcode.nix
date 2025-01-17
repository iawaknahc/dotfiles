{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # qrencode generates QR code locally.
    qrencode
    # zbar offers an executable zbarimg to read QR code locally.
    zbar
  ];
}
