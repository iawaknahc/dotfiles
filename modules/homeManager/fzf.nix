{ config, ... }:
{
  programs.fzf.enable = true;
  programs.fzf.defaultCommand = ''
    fd --type f --hidden
  '';
  programs.fzf.defaultOptions = [
    # Setting --with-shell breaks the CTRL-R key binding introduced by
    # https://github.com/junegunn/fzf/blob/master/shell/key-bindings.fish
    # "--with-shell='sh -c'"
    "--height=40%"
    "--layout=reverse"
    "--border"
  ];

  programs.fzf.enableBashIntegration = true;
  programs.fzf.enableFishIntegration = true;
  programs.fzf.enableZshIntegration = true;
  # FIXME: programs.fzf.enableNushellIntegration does not exist

  home.sessionVariables = {
    # We use atuin to manage shell history.
    # programs.fzf does not offer an option to set this.
    # According to the readme, setting this to empty disable the particular key binding.
    # See https://github.com/junegunn/fzf?tab=readme-ov-file#setting-up-shell-integration
    FZF_CTRL_R_COMMAND = "";
  };
  # FZF_CTRL_T_COMMAND
  programs.fzf.fileWidgetCommand = config.programs.fzf.defaultCommand;
  # FZF_ALT_C_COMMAND
  programs.fzf.changeDirWidgetCommand = "fd --type d --hidden";
}
