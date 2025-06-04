{ pkgs, ... }:
{
  home.packages = with pkgs; [
    _1password-cli
    ast-grep
    bfs
    cloudflared
    delve
    exiftool
    eza
    fastmod
    ffmpeg
    fnlfmt

    # It provides gh-md-toc
    github-markdown-toc-go

    # pprof requires this graph visualization software to generate graphs.
    graphviz

    hadolint

    # xxd with color
    # https://github.com/sweetbbak/hexxy
    hexxy
    # A handy hex viewer, not compatible with xxd.
    # https://github.com/sharkdp/hexyl
    hexyl

    imagemagick

    # https://github.com/jpmens/jo
    jo

    jq

    # The man program itself.
    man
    # The Linux man pages.
    # The entries may be irrelevant to macOS.
    man-pages
    # The POSIX man pages, in particular,
    # the package offers these sections:
    # - 0p: header files (like stdio.h)
    # - 1p: utilities (like sh, awk)
    # - 3p: library functions (like strftime)
    #
    # If you want to access the man page of POSIX sh, you run
    #   man 1p sh
    #
    # In contrast, running
    #   man sh
    # will likely take you to /usr/share/man/man1/sh.1 on macOS.
    #
    # To list all available variants, run
    #   man -aw sh
    # On my system, it prints
    #   /usr/share/man/man1/sh.1
    #   /Users/louischan/.nix-profile/share/man/man1p/sh.1p.gz
    man-pages-posix

    # Metadata anonymisation toolkit 2
    # https://0xacab.org/jvoisin/mat2
    mat2

    nixfmt-rfc-style

    # https://www.passwordstore.org/
    pass

    prettierd
    shellcheck
    shfmt
    tree-sitter
    uv
    wget
  ];
}
