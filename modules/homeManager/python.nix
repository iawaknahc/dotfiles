{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    uv
    ruff

    pyright
    basedpyright
    ty
    pyrefly
  ];
}
