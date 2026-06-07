{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    mypython.version = lib.mkOption {
      type = lib.types.str;
      default = "314";
      description = "The version of Python, e.g 313, 314";
    };

    mypython.pythonPackages = lib.mkOption {
      type = lib.types.attrs;
      default = pkgs."python${config.mypython.version}Packages";
    };

    mypython.packages = lib.mkOption {
      type = lib.types.listOf (lib.types.functionTo (lib.types.listOf lib.types.package));
      default = [ ];
      description = "List of functions to select Python packages";
    };

    mypython.packageFuncs = lib.mkOption {
      type = lib.types.listOf (lib.types.functionTo lib.types.package);
      default = [ ];
      description = "List of functions to modify the resulting Python";
    };

    mypython.package = lib.mkOption {
      type = lib.types.package;
      default =
        let
          pythonWithPackagesInstalled = pkgs."python${config.mypython.version}".withPackages (
            python-pkgs: (builtins.concatMap (selector: selector python-pkgs) config.mypython.packages)
          );
          pythonWithFuncsApplied = builtins.foldl' (
            python: funcToModifyPython: funcToModifyPython python
          ) pythonWithPackagesInstalled config.mypython.packageFuncs;
        in
        pythonWithFuncsApplied;
      description = "The resulting Python";
    };
  };

  config = {
    home.packages = [
      config.mypython.package
      config.mypython.pythonPackages.debugpy
    ];
  };
}
