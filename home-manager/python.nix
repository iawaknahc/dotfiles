{
  pkgs,
  ...
}:
let
  # python3 is usually one version behind.
  pythonVersion = "313";
in
{
  nixpkgs.overlays = [
    (
      final: prev:
      let
        prevPython = prev."python${pythonVersion}";
        prevPythonPackages = prev."python${pythonVersion}Packages";
      in
      {
        mypython = prevPython.withPackages (
          python-pkgs: with python-pkgs; [
            # Timezone handling
            tzdata
            pytz
            tzlocal
            # Clipboard
            pyperclip
            # Parse tiny language
            parsy
            # Terminal output
            rich
            # Manipulating colors
            (prevPythonPackages.buildPythonPackage rec {
              pname = "coloraide";
              version = "4.7.2";
              pyproject = true;
              build-system = [ prevPythonPackages.hatchling ];
              src = prev.fetchPypi {
                inherit pname version;
                hash = "sha256-fomOKtF3hzgJvR9f2x2QYYrYdASf6tlS/0Rw0VdmbUs=";
              };
            })
            # Manipulating fonts
            fonttools
          ]
        );
      }
    )
  ];

  home.packages = [
    pkgs.mypython
    pkgs.ruff
    pkgs.pyright
    pkgs."python${pythonVersion}Packages".json5
    pkgs."python${pythonVersion}Packages".debugpy
  ];
}
