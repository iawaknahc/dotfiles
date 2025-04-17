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
    imagemagick
    jq
    # Metadata anonymisation toolkit 2
    # https://0xacab.org/jvoisin/mat2
    mat2
    nixfmt-rfc-style
    prettierd
    shellcheck
    shfmt
    tree-sitter
    wget
  ];
}
