{
  pkgs,
  config,
  lib,
  ...
}:
let
  enabledEmailAccounts = lib.attrsets.filterAttrs (name: value: value.enable) config.email.accounts;
  # The primary is the first element.
  enabledEmailAccountsList = lib.lists.sort (a: b: a.primary) (
    lib.attrsets.mapAttrsToList (name: value: value) enabledEmailAccounts
  );

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
    else if flavor == "netvigator.com" then
      lib.strings.concatLines [
        ''(:maildir "/${address}/Inbox" :name "Inbox" :key ?i)''
        ''(:maildir "/${address}/Archive" :name "Archive" :key ?a)''
        ''(:maildir "/${address}/Sent" :name "Sent" :key ?s)''
        ''(:maildir "/${address}/Drafts" :name "Drafts" :key ?d)''
        ''(:maildir "/${address}/Trash" :name "Trash" :key ?t)''
        ''(:maildir "/${address}/Junk" :name "Junk" :key ?j)''
      ]
    else if flavor == "davmail" then
      lib.strings.concatLines [
        ''(:maildir "/${address}/Inbox" :name "Inbox" :key ?i)''
        ''(:maildir "/${address}/Archive" :name "Archive" :key ?a)''
        ''(:maildir "/${address}/Sent Items" :name "Sent" :key ?s)''
        ''(:maildir "/${address}/Drafts" :name "Drafts" :key ?d)''
        ''(:maildir "/${address}/Deleted Items" :name "Trash" :key ?t)''
        ''(:maildir "/${address}/Junk Email" :name "Junk" :key ?j)''
        ''(:maildir "/${address}/Outbox" :name "Outbox" :key ?o)''
        ''(:maildir "/${address}/Conversation History" :name "Conversation History" :key ?h)''
      ]
    else
      "";

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
    else if flavor == "netvigator.com" then
      if folder == "sent" then
        "/${address}/Sent"
      else if folder == "drafts" then
        "/${address}/Drafts"
      else if folder == "trash" then
        "/${address}/Trash"
      else if folder == "refile" then
        "/${address}/Archive"
      else
        throw "unknown folder"
    else if flavor == "davmail" then
      if folder == "sent" then
        "/${address}/Sent Items"
      else if folder == "drafts" then
        "/${address}/Drafts"
      else if folder == "trash" then
        "/${address}/Deleted Items"
      else if folder == "refile" then
        "/${address}/Archive"
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
    email.davmail.sopsClientID = lib.mkOption {
      type = lib.types.str;
    };
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
                  "netvigator.com"
                  "davmail"
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

              sopsPassword = lib.mkOption {
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
      davmail
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

    sops.secrets =
      lib.attrsets.concatMapAttrs (
        name: value:
        if value.flavor == "gmail.com" then
          {
            "${value.sopsClientID}" = { };
            "${value.sopsClientSecret}" = { };
          }
        else if value.flavor == "netvigator.com" then
          {
            "${value.sopsPassword}" = { };
          }
        else
          {
          }
      ) enabledEmailAccounts
      // {
        "${config.email.davmail.sopsClientID}" = { };
      };

    # It is required to specify a fixed port because some OAuth providers like Azure, require static redirect URI.
    #
    # When pizauth is run by launchd, it cannot invoke hammerspoon to create notification.
    # So I did not set `auth_notify_cmd` or `error_notify_cmd`.
    sops.templates."pizauth.conf" = {
      mode = "0700";
      path = "${config.xdg.configHome}/pizauth.conf";
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
          else
            ""
        ) enabledEmailAccounts
      );
    };

    sops.templates."davmail.properties" = {
      mode = "0700";
      path = "${config.xdg.configHome}/davmail/davmail.properties";
      content = ''
        davmail.server=true
        davmail.disableUpdateCheck=true
        davmail.allowRemote=false
        davmail.bindAddress=127.0.0.1
        davmail.exitOnBindFailed=true

        davmail.mode=O365Graph
        davmail.authentication=O365Manual
        davmail.enableGraph=true
        davmail.enableOidc=true
        davmail.oauth.persistToken=true
        davmail.oauth.tokenFilePath=${config.xdg.stateHome}/davmail/oauth-tokens.properties
        davmail.oauth.clientId=${config.sops.placeholder."${config.email.davmail.sopsClientID}"}
        davmail.oauth.redirectUri=http://localhost/
        davmail.oauth.tenantId=common

        davmail.caldavPort=1080
        davmail.imapPort=1143
        davmail.ldapPort=1389
        davmail.popPort=1110
        davmail.smtpPort=1025
        davmail.ssl.nosecurecaldav=true
        davmail.ssl.nosecureimap=true
        davmail.ssl.nosecureldap=true
        davmail.ssl.nosecurepop=true
        davmail.ssl.nosecuresmtp=true

        davmail.logFilePath=/dev/stderr
        log4j.logger.davmail=INFO
        log4j.logger.httpclient.wire=WARN
        log4j.logger.httpclient=WARN
        log4j.rootLogger=INFO
      '';
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

    launchd.agents.davmail = {
      enable = true;
      config = {
        Program = "${pkgs.davmail}/bin/davmail";
        ProgramArguments = [
          "${config.xdg.configHome}/davmail/davmail.properties"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/tmp/davmail.stdout";
        StandardErrorPath = "/tmp/davmail.stderr";
      };
    };

    accounts.email.accounts = lib.attrsets.mapAttrs (
      name: value:
      lib.mkMerge [
        (lib.mkIf (value.flavor == "gmail.com") {
          flavor = "gmail.com";
          passwordCommand = "${pkgs.pizauth}/bin/pizauth show ${name}";
          mbsync.extraConfig.account = {
            AuthMechs = "XOAUTH2";
          };
          msmtp.extraConfig = {
            auth = "xoauth2";
          };
        })

        (lib.mkIf (value.flavor == "netvigator.com") {
          flavor = "plain";
          userName = name;
          passwordCommand = "cat ${config.sops.defaultSymlinkPath}/${value.sopsPassword}";
          imap.host = "imap.netvigator.com";
          imap.port = 993;
          imap.tls.enable = true;
          smtp.host = "smtp.netvigator.com";
          smtp.port = 465;
          smtp.tls.enable = true;
        })

        (lib.mkIf (value.flavor == "davmail") {
          flavor = "plain";
          userName = name;
          # The password command is expected to print something, otherwise, mbsync will skip the account.
          passwordCommand = "printf unimportant";
          mbsync.extraConfig.account = {
            # mbsync requires explictitly enabled LOGIN because TLS is not used.
            AuthMechs = "LOGIN";
          };
          imap.host = "localhost";
          imap.port = 1143;
          imap.tls.enable = false;
          smtp.host = "localhost";
          smtp.port = 1025;
          smtp.tls.enable = false;
        })

        {
          inherit (value)
            primary
            realName
            enable
            ;
          address = name;

          mbsync.enable = true;
          mbsync.create = "both"; # Allow mbsync to create necessary local directories.
          mbsync.expunge = "both";
          mu.enable = true;
          msmtp.enable = true;
        }
      ]
    ) enabledEmailAccounts;

    # Use enabledEmailAccountsList so that the first context is the primary account.
    home.file.".emacs.d/lisp/init-mu4e-contexts.el".text = ''
      ;;; -*- lexical-binding: t -*-

      (setq mu4e-contexts (list ${
        lib.strings.concatStrings (lib.lists.map (value: mkMu4eContext value) enabledEmailAccountsList)
      }))

      (provide 'init-mu4e-contexts)
    '';
  };
}
