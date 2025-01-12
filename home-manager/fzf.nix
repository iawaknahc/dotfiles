{ ... }:
{
  programs.fzf.enable = true;
  programs.fzf.defaultCommand = "true";
  programs.fzf.defaultOptions = [
    "--with-shell='sh -c'"
    "--height=40%"
    "--layout=reverse"
    "--border"
  ];
  programs.fzf.enableBashIntegration = false;
  programs.fzf.enableZshIntegration = false;
  programs.fzf.enableFishIntegration = false;
}
