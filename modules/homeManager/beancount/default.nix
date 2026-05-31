{ pkgs, config, ... }:
{
  mypython.packages = [
    (
      python-pkgs: with python-pkgs; [
        beancount
        beanquery
        beangulp
        fava

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
