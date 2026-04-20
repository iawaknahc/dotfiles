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
    # FIXME: mpv depends on yt-dlp which depends on deno, which was not cached at the particular commit I am using.
    mpv-unwrapped
  ];
}
