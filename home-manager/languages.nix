{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    go
    perl
    # python3 is usually one version behind.
    python313
    ruby
  ];
}
