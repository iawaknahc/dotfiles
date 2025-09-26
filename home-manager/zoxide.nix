{ ... }:
{
  # zoxide is a tool bundled in Omarchy
  # https://learn.omacom.io/2/the-omarchy-manual/57/shell-tools#zoxide
  programs.zoxide.enable = true;
  programs.zoxide.enableBashIntegration = true;
  programs.zoxide.enableFishIntegration = true;
  programs.zoxide.enableZshIntegration = true;
  programs.zoxide.enableNushellIntegration = true;
  programs.zoxide.options = [
    # Replace cd.
    "--cmd cd"
  ];
}
