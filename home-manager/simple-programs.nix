{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Secret management
    _1password-cli
    pass # https://www.passwordstore.org/

    # Text processing
    github-markdown-toc-go # It provides gh-md-toc

    # Text processing on binary files.
    # xxd with color
    # https://github.com/sweetbbak/hexxy
    hexxy
    # A handy hex viewer, not compatible with xxd.
    # https://github.com/sharkdp/hexyl
    hexyl

    # Dialects of Chinese
    opencc

    # Database
    duckdb
    sqlite-interactive

    # PostScript and PDF
    qpdf
    poppler-utils
    ghostscript

    # Filesystem
    bfs
    # Interactive du.
    # https://dev.yorhel.nl/ncdu
    ncdu

    # Linter
    hadolint

    # Source code formatter
    prettierd

    # I want the `sponge` program from it.
    # `sponge` is handy when you need to read and write to the same file with programs like `jq` and `sed`.
    moreutils

    # JOSE
    step-cli # https://github.com/smallstep/cli

    # REPL
    rlwrap

    # Kubernetes
    kube-capacity

    # DICOM viewer
    weasis

    # Speech recognition
    openai-whisper

    # Lossless conversion between representations
    remarshal

    # Make without build system
    just
  ];
}
