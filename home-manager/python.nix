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
        markitdown = (
          prevPythonPackages.buildPythonPackage rec {
            pname = "markitdown";
            version = "0.1.2";
            src = prev.fetchPypi {
              inherit pname version;
              hash = "sha256-hf4QipK9GPMX51o2z1Z6b6gSByYSqJir+MFW1ddME8Q=";
            };
            pyproject = true;
            # https://github.com/microsoft/markitdown/blob/v0.1.2/packages/markitdown/pyproject.toml#L2
            build-system = [ prevPythonPackages.hatchling ];
            dependencies = with prevPythonPackages; [
              # https://github.com/microsoft/markitdown/blob/v0.1.2/packages/markitdown/pyproject.toml#L26
              beautifulsoup4
              requests
              markdownify
              magika
              charset-normalizer
              defusedxml

              # https://github.com/microsoft/markitdown/blob/v0.1.2/packages/markitdown/pyproject.toml#L51
              python-pptx

              # https://github.com/microsoft/markitdown/blob/v0.1.2/packages/markitdown/pyproject.toml#L52
              mammoth
              lxml

              # https://github.com/microsoft/markitdown/blob/v0.1.2/packages/markitdown/pyproject.toml#L53
              pandas
              openpyxl
              xlrd

              # https://github.com/microsoft/markitdown/blob/v0.1.2/packages/markitdown/pyproject.toml#L55
              pdfminer-six
            ];
          }
        );
        markitdown-mcp = (
          prevPythonPackages.buildPythonPackage rec {
            pname = "markitdown-mcp";
            version = "0.1.2";
            src = prev.fetchFromGitHub {
              owner = "microsoft";
              repo = "markitdown";
              rev = "v${version}";
              hash = "sha256-7T5cuFBivazKlUk3OKXKKU3YazRAfGRt9O+gCYX3ciQ=";
            };
            sourceRoot = "source/packages/markitdown-mcp";
            pyproject = true;
            build-system = [ prevPythonPackages.hatchling ];
            # It requires mcp ~= 1.8.0 but mcp is > 1.8.0
            dontCheckRuntimeDeps = true;
            dependencies = [
              prevPythonPackages.mcp
              markitdown
            ];
          }
        );
      in
      {
        mypython = prevPython.withPackages (
          python-pkgs: with python-pkgs; [
            # Interactive
            ipython

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

            # MarkItDown
            markitdown
            markitdown-mcp
          ]
        );
      }
    )
  ];

  home.packages = [
    pkgs.mypython
    pkgs.uv
    pkgs.ruff
    pkgs.pyright
    pkgs."python${pythonVersion}Packages".json5
    pkgs."python${pythonVersion}Packages".debugpy
  ];
}
