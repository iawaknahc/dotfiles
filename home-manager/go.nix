{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    go
    delve
    # pprof requires this graph visualization software to generate graphs.
    graphviz
  ];
}
