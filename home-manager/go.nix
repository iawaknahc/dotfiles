{
  pkgs,
  ...
}:
{
  programs.go.enable = true;
  home.packages = with pkgs; [
    delve
    # pprof requires this graph visualization software to generate graphs.
    graphviz
  ];
}
