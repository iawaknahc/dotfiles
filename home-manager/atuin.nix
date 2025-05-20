{ ... }:
{
  programs.atuin.enable = true;
  programs.atuin.daemon.enable = false;

  programs.atuin.flags = [
    # When I press up, I really just want to run the previous command.
    # https://docs.atuin.sh/configuration/key-binding/#disable-up-arrow
    "--disable-up-arrow"
  ];
  programs.atuin.enableBashIntegration = true;
  programs.atuin.enableZshIntegration = true;
  programs.atuin.enableFishIntegration = true;
  programs.atuin.enableNushellIntegration = true;

  programs.atuin.settings = {
    auto_sync = false;
    update_check = false;
    sync_address = "https://0.0.0.0:0";
    enter_accept = false;
    invert = true;
    # Disable the live-updating timestamp for very new history entries.
    prefers_reduced_motion = true;
    dotfiles = {
      enabled = false;
    };
  };
}
