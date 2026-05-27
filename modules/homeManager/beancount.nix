{ pkgs, config, ... }:
{
  mypython.packages = [
    (
      python-pkgs: with python-pkgs; [
        beancount
        beanquery
      ]
    )
  ];

  home.packages = with pkgs; [
    beancount-language-server
    config.mypython.pythonPackages.beancount2ledger
    fava
  ];
}
