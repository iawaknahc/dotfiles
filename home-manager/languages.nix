{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    go
    # nodejs is the latest LTS.
    nodejs
    perl
    # python3 is usually one version behind.
    python313
    ruby
  ];
}
