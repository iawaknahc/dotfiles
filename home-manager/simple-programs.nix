{ pkgs, ... }:
{
  home.packages = with pkgs; [
    _1password-cli
    bfs
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
    nixfmt-rfc-style
    prettierd
    shellcheck
    shfmt
    tree-sitter
    wget
  ];
}