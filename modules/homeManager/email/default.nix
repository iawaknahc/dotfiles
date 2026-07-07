{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    pizauth
  ];

  nixpkgs.overlays = [
    (final: prev: {
      # XOAUTH2 is not enabled by default.
      isync = prev.isync.override {
        withCyrusSaslXoauth2 = true;
      };
    })
  ];

  # This program synchronize emails with a remote server.
  programs.mbsync.enable = true; # The configuration of this program is at ~/.config/isyncrc

  # This program indexes local emails for searching.
  programs.mu.enable = true;

  # This program sends emails.
  # In particular, it also provides the executable `sendmail` which Emacs can use.
  programs.msmtp.enable = true; # The configuration of this program is at ~/.config/msmtp/config

  sops.secrets."accounts/louischan0325_at_gmail_dot_com/app_password" = { };
  sops.secrets."accounts/louischan0325_at_gmail_dot_com/pizauth/client_id" = { };
  sops.secrets."accounts/louischan0325_at_gmail_dot_com/pizauth/client_secret" = { };
  sops.templates."pizauth.conf" = {
    mode = "0700";
    content = ''
      auth_notify_cmd = "${pkgs.hammerspoon}/bin/hs -c 'hs.notify.new(function() hs.urlevent.openURL(_cli.args[3]) end, { title = [[Authenticate ]] .. _cli.args[2], alwaysPresent = true, withdrawAfter = 0 }):send()' -- \"$PIZAUTH_ACCOUNT\" \"$PIZAUTH_URL\"";
      error_notify_cmd = "${pkgs.hammerspoon}/bin/hs -c 'hs.notify.new({ title = _cli.args[2] .. [[ ]] .. _cli.args[3], alwaysPresent = true, withdrawAfter = 0 }):send()' -- \"$PIZAUTH_ACCOUNT\" \"$PIZAUTH_MSG\"";

      account "louischan0325@gmail.com" {
        auth_uri = "https://accounts.google.com/o/oauth2/auth";
        auth_uri_fields = {"login_hint": "louischan0325@gmail.com"};
        token_uri = "https://oauth2.googleapis.com/token";
        scopes = ["https://mail.google.com/"];
        client_id = "${
          config.sops.placeholder."accounts/louischan0325_at_gmail_dot_com/pizauth/client_id"
        }";
        client_secret = "${
          config.sops.placeholder."accounts/louischan0325_at_gmail_dot_com/pizauth/client_secret"
        }";
      }
    '';
    path = "${config.home.homeDirectory}/.config/pizauth.conf";
  };

  launchd.agents.pizauth = {
    enable = true;
    config = {
      Program = "${pkgs.pizauth}/bin/pizauth";
      ProgramArguments = [
        "server"
        "-d" # Do not daemonize.
        "-vvvv" # Enable most verbose logging.
        "-c" # Give an explicit path to the configuration so that XDG_* or HOME is not required.
        "${config.sops.templates."pizauth.conf".path}"
      ];
      EnvironmentVariables = {
        # According to `man pizauth.conf`, pizauth reads SHELL to determine which shell to use.
        SHELL = "${pkgs.bash}";
      };
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/pizauth.stdout";
      StandardErrorPath = "/tmp/pizauth.stderr";
    };
  };

  accounts.email.accounts."louischan0325@gmail.com" = {
    primary = true; # Exactly one of the accounts has to be marked as primary.

    flavor = "gmail.com";
    address = "louischan0325@gmail.com";
    realName = "Louis Chan";

    passwordCommand = "${pkgs.pizauth}/bin/pizauth show louischan0325@gmail.com";

    mbsync.enable = true;
    mbsync.create = "both"; # Allow mbsync to create necessary local directories.
    mbsync.expunge = "both";
    mbsync.extraConfig.account = {
      AuthMechs = "XOAUTH2";
    };

    mu.enable = true;

    msmtp.enable = true;
  };
}
