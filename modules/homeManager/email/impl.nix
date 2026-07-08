{
  pkgs,
  config,
  lib,
  ...
}:
let
  enabledEmailAccounts = lib.attrsets.filterAttrs (name: value: value.enable) config.email.accounts;

  mkMaildirShortcuts =
    flavor: address:
    if flavor == "gmail.com" then
      lib.strings.concatLines [
        ''(:maildir "/${address}/Inbox" :name "Inbox" :key ?i)''
        ''(:maildir "/${address}/[Gmail]/All Mail" :name "Archive" :key ?a)''
        ''(:maildir "/${address}/[Gmail]/Sent Mail" :name "Sent" :key ?s)''
        ''(:maildir "/${address}/[Gmail]/Drafts" :name "Drafts" :key ?d)''
        ''(:maildir "/${address}/[Gmail]/Trash" :name "Trash" :key ?t)''
        ''(:maildir "/${address}/[Gmail]/Spam" :name "Junk" :key ?j)''
      ]
    else
      throw "unknown flavor";

  folderFor =
    flavor: address: folder:
    if flavor == "gmail.com" then
      if folder == "sent" then
        "/${address}/[Gmail]/Sent Mail"
      else if folder == "drafts" then
        "/${address}/[Gmail]/Drafts"
      else if folder == "trash" then
        "/${address}/[Gmail]/Trash"
      else if folder == "refile" then
        "/${address}/[Gmail]/All Mail"
      else
        throw "unknown folder"
    else
      throw "unknown flavor";

  mkMu4eContext = (
    account:
    let
      f = folderFor account.flavor account.address;
    in
    ''
      (make-mu4e-context
        :name "${account.mu4eContextName}"
        :vars '((user-full-name . "${account.realName}")
                (user-mail-address . "${account.address}")
                (mu4e-sent-folder . "${f "sent"}")
                (mu4e-drafts-folder . "${f "drafts"}")
                (mu4e-trash-folder . "${f "trash"}")
                (mu4e-refile-folder . "${f "refile"}")
                (mu4e-maildir-shortcuts . (${mkMaildirShortcuts account.flavor account.address}))))
    ''
  );
in
{
  options = {
    email.enable = lib.mkEnableOption "email";
    email.accounts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }: {
            config = {
              inherit name;
              address = name;
            };
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                readOnly = true;
              };
              address = lib.mkOption {
                type = lib.types.str;
                readOnly = true;
              };

              enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
              };

              primary = lib.mkOption {
                type = lib.types.bool;
                default = false;
              };

              flavor = lib.mkOption {
                type = lib.types.enum [
                  "gmail.com"
                  "outlook.office365.com"
                ];
              };

              realName = lib.mkOption {
                type = lib.types.str;
              };

              mu4eContextName = lib.mkOption {
                type = lib.types.str;
              };

              sopsClientID = lib.mkOption {
                type = lib.types.str;
              };
              sopsClientSecret = lib.mkOption {
                type = lib.types.str;
              };
            };
          }
        )
      );
    };
  };

  config = lib.mkIf config.email.enable {
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

    sops.secrets = lib.attrsets.concatMapAttrs (name: value: {
      "${value.sopsClientID}" = { };
      "${value.sopsClientSecret}" = { };
    }) enabledEmailAccounts;

    # It is required to specify a fixed port because some OAuth providers like Azure, require static redirect URI.
    #
    # When pizauth is run by launchd, it cannot invoke hammerspoon to create notification.
    # So I did not set `auth_notify_cmd` or `error_notify_cmd`.
    sops.templates."pizauth.conf" = {
      mode = "0700";
      path = "${config.home.homeDirectory}/.config/pizauth.conf";
      content = ''
        http_listen = "127.0.0.1:8001";
        https_listen = "127.0.0.1:8002";

      ''
      + lib.strings.concatStrings (
        lib.attrsets.mapAttrsToList (
          name: value:
          if value.flavor == "gmail.com" then
            ''
              account "${name}" {
                auth_uri = "https://accounts.google.com/o/oauth2/auth";
                auth_uri_fields = {"login_hint": "${name}"};
                token_uri = "https://oauth2.googleapis.com/token";
                scopes = ["https://mail.google.com/"];
                client_id = "${config.sops.placeholder."${value.sopsClientID}"}";
                client_secret = "${config.sops.placeholder."${value.sopsClientSecret}"}";
                redirect_uri = "http://localhost:8001/";
              }

            ''
          else if value.flavor == "outlook.office365.com" then
            ''
              account "${name}" {
                auth_uri = "https://login.microsoftonline.com/common/oauth2/v2.0/authorize";
                auth_uri_fields = { "login_hint": "${name}" };
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
                client_id = "${config.sops.placeholder."${value.sopsClientID}"}";
                client_secret = "${config.sops.placeholder."${value.sopsClientSecret}"}";
                redirect_uri = "http://localhost:8001/";
              }

            ''
          else
            ""
        ) enabledEmailAccounts
      );
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

    accounts.email.accounts = lib.attrsets.mapAttrs (name: value: {
      inherit (value)
        primary
        flavor
        realName
        enable
        ;
      address = name;

      passwordCommand = "${pkgs.pizauth}/bin/pizauth show ${name}";

      mbsync.enable = true;
      mbsync.create = "both"; # Allow mbsync to create necessary local directories.
      mbsync.expunge = "both";
      mbsync.extraConfig.account = {
        AuthMechs = "XOAUTH2";
      };
      mu.enable = true;
      msmtp.enable = true;
    }) enabledEmailAccounts;

    home.file.".emacs.d/mu4e-contexts.el".text = ''
      (setq mu4e-contexts (list ${
        lib.strings.concatStrings (
          lib.attrsets.mapAttrsToList (name: value: mkMu4eContext value) enabledEmailAccounts
        )
      }))
    '';
  };
}
