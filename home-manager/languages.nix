{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    perl
    ruby
  ];
}
