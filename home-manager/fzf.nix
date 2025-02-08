{ pkgs, ... }:
{
  # Do not use programs.fzf because we do not want to unset the shell integrations.
  home.packages = with pkgs; [
    fzf
  ];
  home.sessionVariables = {
    FZF_DEFAULT_COMMAND = "true";
    FZF_DEFAULT_OPTS = builtins.toString [
      "--with-shell='sh -c'"
      "--height=40%"
      "--layout=reverse"
      "--border"
    ];
  };
}
