{ pkgs, ... }:
{
  programs.mpv.enable = true;

  home.packages = with pkgs; [
    # Image
    exiftool
    imagemagick
    # FIXME: On 2026-07-16, mat2 failed to build.
    # mat2 # https://0xacab.org/jvoisin/mat2
    tesseract
    qrencode # Write QR code
    zbar # Read QR code

    # Audio and video
    ffmpeg
  ];
}
