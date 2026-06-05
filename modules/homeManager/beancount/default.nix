{ pkgs, config, ... }:
{
  mypython.packages = [
    (
      python-pkgs: with python-pkgs; [
        beancount
        beanquery
        beangulp
        fava

        autobean_refactor
        # I tried autobean_format on 2026-06-05, but it was just too slow.
        # autobean_format

        # I replaced beanprice with pricehist with a custom script to invoke it.
        # See pricehist-bean.py
        #
        # If we decide to switch back to beanprice in the future,
        # we have to package it with buildPythonPackage so that it resides along with our plugins.
        # Otherwise, `beanprice main.beancount` will complain about `my_plugins` not found.
        #beanprice
        pricehist

        (config.mypython.pythonPackages.buildPythonPackage {
          pname = "my_plugins";
          version = "1.0.0";
          pyproject = true;
          build-system = [ setuptools ];
          dependencies = [
            beancount
          ];
          src = ./my_plugins;
        })
      ]
    )
  ];

  home.packages = with pkgs; [
    beancount-language-server
    # Ideally, beancount2ledger should be installed as a Python package.
    # But it requires a specific version of setuptools which is incompatible with the version of setuptools on nixpkgs.
    config.mypython.pythonPackages.beancount2ledger
  ];
}
