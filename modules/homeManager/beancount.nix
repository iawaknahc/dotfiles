{ pkgs, ... }:
{
  home.packages = with pkgs; [
    beancount-language-server
    beancount2ledger
    fava
  ];
}
