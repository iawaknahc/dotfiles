{ ... }:
{
  # eza is a tool bundled in Omarchy
  # https://learn.omacom.io/2/the-omarchy-manual/57/shell-tools#eza
  programs.eza.enable = true;
  programs.eza.enableBashIntegration = true;
  programs.eza.enableFishIntegration = true;
  programs.eza.enableZshIntegration = true;
  programs.eza.enableNushellIntegration = false; # We are not going to override `ls` in Nushell.
  # What eza is missing is order of columns.
  # The order of the original `ls -l` is
  # - permission
  # - links
  # - user
  # - group
  # - size
  # - mtime
  # - name
  # See https://github.com/eza-community/eza/issues/148
  programs.eza.extraOptions = [
    # Though the manpage says --classify=automatic by default,
    # `ls` does not classify at all.
    "--classify=automatic"

    # These two flags make the output match closer to `ls -l`
    "--links"
    "--group"

    "--git"
  ];

  # Just configure lsd as a comparison to eza.
  # The shell integrations are not enabled.
  programs.lsd.enable = true;
  programs.lsd.settings = {
    icons = {
      when = "never";
    };
    indicators = true;
    blocks = [
      "permission"
      "links"
      "user"
      "group"
      "size"
      "date"
      "git"
      "name"
    ];
  };
}
