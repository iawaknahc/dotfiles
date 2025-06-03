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
