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

        tabulate

        pyxirr

        whenever

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

  # We wrap bean-format so that it behaves deterministically.
  # The indentation is 2-space, and it counts column from 1.
  # The flag `--currency-column 76` means preserving 75 characters for indentation, account, and the number of the amount.
  # 76 is chosen to ensure that most of time when I use vertical split in Neovim, the posting line does not wrap.
  # The flag `--prefix-width` allocates 45 character for account.
  # The flag `--num-width` allocates 30 character for the number of the amount.
  mypython.packageFuncs = [
    (
      python:
      python.overrideAttrs (prev: {
        postBuild = prev.postBuild + ''
          wrapProgram $out/bin/bean-format \
            --add-flag "--prefix-width" \
            --add-flag "45" \
            --add-flag "--num-width" \
            --add-flag "30" \
            --add-flag "--currency-column" \
            --add-flag "76"
        '';
      })
    )
  ];

  home.packages = with pkgs; [
    beancount-language-server

    # Ideally, beancount2ledger should be installed as a Python package.
    # But it requires a specific version of setuptools which is incompatible with the version of setuptools on nixpkgs.
    config.mypython.pythonPackages.beancount2ledger
  ];
}
