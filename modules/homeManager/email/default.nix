{ config, ... }:
{
  # This program synchronize emails with a remote server.
  programs.mbsync.enable = true; # The configuration of this program is at ~/.config/isyncrc

  # This program indexes local emails for searching.
  programs.mu.enable = true;

  # This program sends emails.
  # In particular, it also provides the executable `sendmail` which Emacs can use.
  programs.msmtp.enable = true; # The configuration of this program is at ~/.config/msmtp/config

  sops.secrets."accounts/louischan0325_at_gmail_dot_com/app_password" = { };

  accounts.email.accounts."louischan0325@gmail.com" = {
    primary = true; # Exactly one of the accounts has to be marked as primary.

    flavor = "gmail.com";
    address = "louischan0325@gmail.com";
    realName = "Louis Chan";

    passwordCommand = "cat ${config.home.homeDirectory}/.config/sops-nix/secrets/accounts/louischan0325_at_gmail_dot_com/app_password";

    mbsync.enable = true;
    mbsync.create = "both"; # Allow mbsync to create necessary local directories.
    mbsync.expunge = "both";

    mu.enable = true;

    msmtp.enable = true;
  };
}
