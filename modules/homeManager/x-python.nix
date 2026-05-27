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
      default = "313";
      description = "The version of Python, e.g 313, 314";
    };

    mypython.packages = lib.mkOption {
      type = lib.types.listOf (lib.types.functionTo (lib.types.listOf lib.types.package));
      default = [ ];
      description = "List of functions to select Python packages";
    };

    mypython.pythonPackages = lib.mkOption {
      type = lib.types.attrs;
      default = pkgs."python${config.mypython.version}Packages";
    };

    mypython.package = lib.mkOption {
      type = lib.types.package;
      default = pkgs."python${config.mypython.version}".withPackages (
        python-pkgs: (builtins.concatMap (selector: selector python-pkgs) config.mypython.packages)
      );
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
