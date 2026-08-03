{ pkgs, ... }:
{
  mypython.packages = [
    (
      python-pkgs: with python-pkgs; [
        # Lossless conversion between representations
        remarshal
      ]
    )
  ];

  home.packages = with pkgs; [
    # Secret management
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
    (openai-whisper.overrideAttrs (prev: {
      # FIXME: The test involving invoking ffmpeg, but it was killed with signal 9. Maybe related to https://github.com/NixOS/nixpkgs/issues/507531
      disabledTests = prev.disabledTests ++ [ "test_audio" ];
    }))

    # Make without build system
    just

    # https://github.com/xampprocky/tokei
    tokei
  ];
}
