{ pkgs, ... }:
{
  programs.mpv.enable = true;

  home.packages = with pkgs; [
    # Image
    exiftool
    imagemagick
    # FIXME: mat2 failed to build on macOS since around 2026-07-16
    # See https://github.com/NixOS/nixpkgs/issues/546115
    # See https://github.com/NixOS/nixpkgs/pull/546126
    # mat2 # https://0xacab.org/jvoisin/mat2
    tesseract
    qrencode # Write QR code
    zbar # Read QR code

    # Audio and video
    ffmpeg
  ];
}
