{ ... }:
{
  # eza is a tool bundled in Omarchy
  # https://learn.omacom.io/2/the-omarchy-manual/57/shell-tools#eza
  programs.eza.enable = true;
  programs.eza.enableBashIntegration = true;
  programs.eza.enableFishIntegration = true;
  programs.eza.enableNushellIntegration = true;
  programs.eza.enableZshIntegration = true;
  programs.eza.extraOptions = [
    # Though the manpage says --classify=automatic by default,
    # `ls` does not classify at all.
    "--classify=automatic"

    # These two flags make the output match closer to `ls -l`
    "--links"
    "--group"

    "--git"
    "--time-style=+%Y-%m-%d %H:%M:%S %z"
  ];
}
