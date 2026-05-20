{ pkgs, ... }:
{
  home.packages = with pkgs; [
    beancount
    beancount-language-server
    beanquery
    fava
  ];
}
