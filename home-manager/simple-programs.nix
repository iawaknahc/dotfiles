{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Secret management
    _1password-cli
    pass # https://www.passwordstore.org/

    # Text processing
    ast-grep
    fastmod
    github-markdown-toc-go # It provides gh-md-toc

    # Text processing on binary files.
    # xxd with color
    # https://github.com/sweetbbak/hexxy
    hexxy
    # A handy hex viewer, not compatible with xxd.
    # https://github.com/sharkdp/hexyl
    hexyl

    # IP and CIDR
    subnetcalc
    ipcalc

    # Database
    duckdb
    sqlite-interactive

    # JSON
    jo # https://github.com/jpmens/jo
    jq

    # PostScript and PDF
    qpdf
    poppler-utils
    ghostscript

    # Filesystem
    bfs
    eza
    # Interactive du.
    # https://dev.yorhel.nl/ncdu
    ncdu

    # Linter
    hadolint
    shellcheck

    # Source code formatter
    nixfmt-rfc-style
    prettierd
    shfmt

    # Downloader
    wget

    # Image processing
    exiftool
    imagemagick
    # Metadata anonymisation toolkit 2
    # https://0xacab.org/jvoisin/mat2
    mat2
    tesseract # OCR
    qrencode # Write QR code

    # FIXME: https://github.com/NixOS/nixpkgs/issues/338863
    #
    # The test of zbar failed to run on my machine.
    # zbar # Read QR code

    # Multimedia processing
    ffmpeg

    # I want the `sponge` program from it.
    # `sponge` is handy when you need to read and write to the same file with programs like `jq` and `sed`.
    moreutils

    # JOSE
    step-cli # https://github.com/smallstep/cli

    # REPL
    rlwrap

    # Misc
    cloudflared
  ];
}
