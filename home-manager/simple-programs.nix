{ pkgs, ... }:
{
  home.packages = [
    pkgs._1password-cli
    pkgs.bfs
    pkgs.delve
    pkgs.exiftool
    pkgs.eza
    pkgs.fastmod
    pkgs.ffmpeg
    pkgs.fnlfmt
    # It provides gh-md-toc
    pkgs.github-markdown-toc-go
    # pprof requires this graph visualization software to generate graphs.
    pkgs.graphviz
    pkgs.hadolint
    pkgs.imagemagick
    pkgs.jq
    pkgs.nixfmt-rfc-style
    pkgs.prettierd
    pkgs.shellcheck
    pkgs.shfmt
    pkgs.wget
  ];
}
