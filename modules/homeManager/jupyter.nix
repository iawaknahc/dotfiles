{ pkgs, config, ... }:
{
  mypython.packages = [
    (
      python-pkgs: with python-pkgs; [
        ipython
        jupyter-core
        jupyter-console
        # notebook somehow depends on json5
        # Thus, json5 has to be installed here, not in home.packages.
        # Otherwise, there would be symlink clash in ~/.nix-profile/bin
        notebook
        json5

        # Jupyter kernels
        # string.<Tab> will NOT show the functions under string.
        # Instead, it show functions in the global namespace.
        # So it is not very useful.
        ilua
      ]
    )
  ];

  home.packages = with pkgs; [
    # Jupyter kernels
    # Invoking iruby will immediately exit with 2.
    # jupyter console --kernel=ruby is fine though.
    iruby

    # import "fmt"
    # fmt.<Tab> and it will crash.
    # So it is not usable at all.
    # Consider using https://github.com/janpfeifer/gonb
    # pkgs.gophernotes
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

  # From IPython 9, highlighting_style is deprecated.
  # See https://github.com/catppuccin/python/issues/111
  home.file.".ipython/profile_default/ipython_config.py".text = ''
    c.TerminalInteractiveShell.true_color = True
    c.TerminalInteractiveShell.highlighting_style = "catppuccin-mocha"
  '';
}
