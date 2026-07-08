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

  sops.secrets."pizauth/google/client_id" = { };
  sops.secrets."pizauth/google/client_secret" = { };

  # 1. Visit https://portal.azure.com
  # 2. Go to Entra ID
  # 3. Create an application.
  #   3.1. It must be a Web application, not a Desktop application. Otherwise, it is considered as public client and client secret is disallowed.
  #        What makes debugging hard is that pizauth outputs no log when the token endpoint returns an error saying that public client is not allowed to use client secret.
  #        I figured this out myself by running the OAuth request with cURL.
  #        The redirect URI is associated with the type of the application. Specify the redirect URI matching the configuration of pizauth below.
  #   3.2. The supported account types must be "Any Entra ID Tenant + Personal Microsoft accounts". When this account type is used, the tenant is `common`.
  # 4. Create a client secret. It is always expiring.
  # 5. Grant `offline_grant` to the application.
  #
  # See https://learn.microsoft.com/en-us/exchange/client-developer/legacy-protocols/how-to-authenticate-an-imap-pop-smtp-application-by-using-oauth
  sops.secrets."pizauth/azure/client_id" = { };
  sops.secrets."pizauth/azure/client_secret" = { };

  # It is required to specify a fixed port because some OAuth providers like Azure, require static redirect URI.
  #
  # When pizauth is run by launchd, it cannot invoke hammerspoon to create notification.
  # So I did not set `auth_notify_cmd` or `error_notify_cmd`.
  sops.templates."pizauth.conf" = {
    mode = "0700";
    content = ''
      http_listen = "127.0.0.1:8001";
      https_listen = "127.0.0.1:8002";

      account "louischan0325@gmail.com" {
        auth_uri = "https://accounts.google.com/o/oauth2/auth";
        auth_uri_fields = {"login_hint": "louischan0325@gmail.com"};
        token_uri = "https://oauth2.googleapis.com/token";
        scopes = ["https://mail.google.com/"];
        client_id = "${config.sops.placeholder."pizauth/google/client_id"}";
        client_secret = "${config.sops.placeholder."pizauth/google/client_secret"}";
        redirect_uri = "http://localhost:8001/";
      }

      account "louischan0325@hotmail.com" {
        auth_uri = "https://login.microsoftonline.com/common/oauth2/v2.0/authorize";
        auth_uri_fields = { "login_hint": "louischan0325@hotmail.com" };
        token_uri = "https://login.microsoftonline.com/common/oauth2/v2.0/token";
        scopes = [
          "https://outlook.office.com/IMAP.AccessAsUser.All",
          "https://outlook.office.com/POP.AccessAsUser.All",
          "https://outlook.office.com/SMTP.Send",
          "https://graph.microsoft.com/IMAP.AccessAsUser.All",
          "https://graph.microsoft.com/POP.AccessAsUser.All",
          "https://graph.microsoft.com/SMTP.Send",
          "offline_access"
        ];
        client_id = "${config.sops.placeholder."pizauth/azure/client_id"}";
        client_secret = "${config.sops.placeholder."pizauth/azure/client_secret"}";
        redirect_uri = "http://localhost:8001/";
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

  accounts.email.accounts."louischan0325@gmail.com" = { name, ... }: {
    primary = true; # Exactly one of the accounts has to be marked as primary.

    flavor = "gmail.com";
    address = name;
    realName = "Louis Chan";

    passwordCommand = "${pkgs.pizauth}/bin/pizauth show ${name}";

    mbsync.enable = true;
    mbsync.create = "both"; # Allow mbsync to create necessary local directories.
    mbsync.expunge = "both";
    mbsync.extraConfig.account = {
      AuthMechs = "XOAUTH2";
    };
    mu.enable = true;
    msmtp.enable = true;
  };

  # On 2026-07-08, I successfully set up pizauth to obtain access token.
  # But when the access token was used to access the account via IMAP
  # The error message "User is authenticated but not connected." was shown.
  # https://learn.microsoft.com/en-us/answers/questions/5673167/imap-oauth-regression-user-is-authenticated-but-no
  #
  # Some Google results suggested that IMAP has to be enabled on outlook.com.
  # I checked and it is enabled for this account.
  #
  # Asking LLM does not give any working answer neither.
  #
  # So we can only disable this account at the moment.
  accounts.email.accounts."louischan0325@hotmail.com" = { name, ... }: {
    flavor = "outlook.office365.com";
    address = name;
    realName = "Louis Chan";

    passwordCommand = "${pkgs.pizauth}/bin/pizauth show ${name}";

    mbsync.enable = false;
    mbsync.create = "both"; # Allow mbsync to create necessary local directories.
    mbsync.expunge = "both";
    mbsync.extraConfig.account = {
      AuthMechs = "XOAUTH2";
    };
    mu.enable = false;
    msmtp.enable = false;
  };
}
