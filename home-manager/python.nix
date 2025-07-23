{
  pkgs,
  config,
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
              # typer is a dependency of mcp
              # https://github.com/modelcontextprotocol/python-sdk/issues/409
              # If we do not install typer, running `python3 -m pydoc -k anythingquery` will result in
              #   Error: typer is required. Install with 'pip install mcp[cli]'
              prevPythonPackages.typer
              markitdown
            ];
          }
        );
      in
      {
        mypython = prevPython.withPackages (
          python-pkgs: with python-pkgs; [
            # Colorscheme
            catppuccin

            # JSON5
            json5

            # Lisp
            hy

            # Jupyter
            ipython
            jupyter-core
            jupyter-console
            # notebook somehow depends on json5
            # Thus, json5 has to be installed here, not in home.packages.
            # Otherwise, there would be symlink clash in ~/.nix-profile/bin
            notebook

            # Jupyter kernels
            # string.<Tab> will NOT show the functions under string.
            # Instead, it show functions in the global namespace.
            # So it is not very useful.
            ilua

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

  # Revert the hard-coded style of jupyter_console.
  # https://github.com/jupyter/jupyter_console/blob/v6.6.3/jupyter_console/ptshell.py#L512-L533
  home.file.".jupyter/jupyter_console_config.py".text = ''
    from pygments.styles import get_style_by_name
    from pygments.token import Token

    style_name = "catppuccin-mocha"
    style_cls = get_style_by_name(style_name)
    style = style_cls()

    styles_dict = style.styles

    c.ZMQTerminalInteractiveShell.true_color = True
    c.ZMQTerminalInteractiveShell.highlighting_style = style_name
    c.ZMQTerminalInteractiveShell.highlighting_style_overrides = {
        Token.Prompt: "ansigreen",
        Token.PromptNum: "ansigreen bold",
        Token.OutPrompt: "ansired",
        Token.OutPromptNum: "ansired bold",
        Token.RemotePrompt: "",
        Token.Number: styles_dict[Token.Literal.Number],
        Token.Operator: styles_dict[Token.Operator],
        Token.String: styles_dict[Token.Literal.String],
        Token.Name.Function: styles_dict[Token.Name.Function],
        Token.Name.Class: styles_dict[Token.Name.Class],
        Token.Name.Namespace: styles_dict[Token.Name.Namespace],
    }
  '';
  # From IPython 9, highlighting_style is deprecated.
  # See https://github.com/catppuccin/python/issues/111
  home.file.".ipython/profile_default/ipython_config.py".text = ''
    c.TerminalInteractiveShell.true_color = True
    c.TerminalInteractiveShell.highlighting_style = "catppuccin-mocha"
  '';

  home.packages = [
    pkgs.mypython
    pkgs.uv
    pkgs.ruff
    pkgs.pyright
    pkgs."python${pythonVersion}Packages".debugpy

    # Jupyter kernels
    # Invoking iruby will immediately exit with 2.
    # jupyter console --kernel=ruby is fine though.
    pkgs.iruby

    # import "fmt"
    # fmt.<Tab> and it will crash.
    # So it is not usable at all.
    # Consider using https://github.com/janpfeifer/gonb
    # pkgs.gophernotes
  ];

  home.file."Library/Jupyter/kernels/ruby/kernel.json".text = builtins.toJSON {
    language = "ruby";
    display_name = "Ruby";
    argv = [
      "${config.home.profileDirectory}/bin/iruby"
      "kernel"
      "{connection_file}"
    ];
  };

  home.file."Library/Jupyter/kernels/lua/kernel.json".text = builtins.toJSON {
    language = "lua";
    display_name = "Lua";
    argv = [
      "${config.home.profileDirectory}/bin/python3"
      "-m"
      "ilua.app"
      "-c"
      "{connection_file}"
    ];
  };
}
