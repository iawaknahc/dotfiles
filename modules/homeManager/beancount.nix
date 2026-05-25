{ pkgs, ... }:
{
  home.packages = with pkgs; [
    beancount
    beancount-language-server
    beancount2ledger
    beanquery
    fava
  ];
}
