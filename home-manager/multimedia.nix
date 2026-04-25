{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Image
    exiftool
    imagemagick
    mat2 # https://0xacab.org/jvoisin/mat2
    tesseract
    qrencode # Write QR code
    zbar # Read QR code

    # Audio and video
    ffmpeg
    mpv
  ];
}
