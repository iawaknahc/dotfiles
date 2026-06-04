{ pkgs, config, ... }:
{
  mypython.packages = [
    (
      python-pkgs: with python-pkgs; [
        beancount
        beanquery
        beangulp
        fava
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

        # beanprice is built by buildPythonApplication.
        # But we need to it to be built by buildPythonPackage so that it resides along with our plugins.
        # Otherwise, `beanprice main.beancount` will complain about `my_plguins` not found.
        (
          let
            beanprice = pkgs.beanprice.override {
              python3Packages = python-pkgs;
            };
          in
          config.mypython.pythonPackages.buildPythonPackage {
            name = beanprice.name;
            version = beanprice.version;
            pyproject = beanprice.pyproject;
            src = beanprice.src;
            build-system = beanprice.build-system;
            dependencies = beanprice.dependencies;
            # Skip the check because nativeCheckInputs is not available in the final package.
            doCheck = false;
            pythonImportsCheck = beanprice.pythonImportsCheck;
          }
        )
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
