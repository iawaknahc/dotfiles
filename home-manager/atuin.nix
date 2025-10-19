{ config, ... }:
{
  programs.atuin.enable = true;
  programs.atuin.daemon.enable = false;

  programs.atuin.flags = [
    # When I press up, I really just want to run the previous command.
    # https://docs.atuin.sh/configuration/key-binding/#disable-up-arrow
    "--disable-up-arrow"
  ];

  # FIXME: https://github.com/NixOS/nixpkgs/issues/449970
  # The bash shell integration of atuin has this dependency chain:
  # atuin -> bash-preexec -> bats -> flock -> ronn -> nokogiri
  programs.atuin.enableBashIntegration = false;
  programs.bash.bashrcExtra = ''
    unset HISTFILE
  '';

  programs.atuin.enableZshIntegration = true;
  programs.zsh.initContent = ''
    unset HISTFILE
  '';

  programs.atuin.enableFishIntegration = true;
  # https://fishshell.com/docs/current/interactive.html#searchable-command-history
  # https://fishshell.com/docs/current/interactive.html#private-mode
  # Atuin respects fish_private_mode, when fish_private_mode is on, Atuin does not save history.
  # Other than fish_private_mode, fish shell does not record a command if it is prefixed with a space,
  # similar to HISTCONTROL=ignorespace.

  # nushell does not seem to have a way to disable history at all.
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
    history_filter = [
      # Ignore any command that starts with 1 or more spaces.
      # Basically it is HISTCONTROL=ignorespace
      "^ +"
    ];
  };
}
