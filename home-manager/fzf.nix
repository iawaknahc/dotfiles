{ pkgs, ... }:
{
  # Do not use programs.fzf because we do not want to unset the shell integrations.
  home.packages = with pkgs; [
    fzf
  ];
  home.sessionVariables = {
    FZF_DEFAULT_COMMAND = "true";
    FZF_DEFAULT_OPTS = builtins.toString [
      # Setting --with-shell breaks the CTRL-R key binding introduced by
      # https://github.com/junegunn/fzf/blob/master/shell/key-bindings.fish
      # "--with-shell='sh -c'"

      "--height=40%"
      "--layout=reverse"
      "--border"
    ];
  };
}
