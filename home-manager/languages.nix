{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    go
    perl
    ruby
  ];
}
