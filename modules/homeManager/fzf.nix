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
  # FIXME: Enable fzf nushell integration.
  programs.fzf.enableNushellIntegration = false;

  # FZF_CTRL_R_COMMAND
  # We use atuin to manage shell history.
  programs.fzf.historyWidget.command = "";
  # FZF_ALT_C_COMMAND
  programs.fzf.changeDirWidget.command = "fd --type d --hidden";
  # FZF_CTRL_T_COMMAND
  programs.fzf.fileWidget.command = config.programs.fzf.defaultCommand;
}
