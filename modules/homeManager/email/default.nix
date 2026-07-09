{
  imports = [ ./impl.nix ];

  config = {
    email.enable = true;

    email.accounts."louischan0325@gmail.com" = {
      primary = true;
      flavor = "gmail.com";
      realName = "Louis Chan";
      mu4eContextName = "gmail";

      sopsClientID = "pizauth/google/client_id";
      sopsClientSecret = "pizauth/google/client_secret";
    };

    email.accounts."chankawai49@netvigator.com" = {
      flavor = "netvigator.com";
      realName = "Louis Chan";
      mu4eContextName = "netvigator";

      sopsPassword = "chankawai49_at_netvigator_dot_com/password";
    };

    email.accounts."louischan0325@hotmail.com" = {
      # As of davmail 6.8.0, it does not run an HTTP server to handle the OAuth redirect URI.
      # Instead, it expects us to copy the redirect URI and paste it to the terminal.
      # Therefore, the value of the redirect URI really does not matter, as long as it is an allowed redirect URI.
      #
      # Here are the steps to create an OAuth2 application.
      # 1. Visit https://portal.azure.com
      # 2. Go to "Microsoft Entra ID"
      # 3. Go to "App registrations"
      # 4. Create a client with a redirect URI of native client. A native client does not (and cannot) use client secret.
      #    Use "http://localhost/" as the redirect URI, as mentioned above, no server is expected to be running at 127.0.0.1:80
      # 5. Go to "Manage -> Authentication"
      #   5.1. Go to "Settings". Make sure "Allow public client flows" is enabled.
      #   5.2. Go to "Supported Accounts". Make sure it is "Any Entra ID Tenant + Personal Microsoft accounts".
      #   5.3. Go to "Redirect URI configuration". Make sure there is a "Mobile and desktop applications" with redirect URI "http://localhost/".
      # 6. Go to "Manage -> API permissions"
      #   6.1. Add the scope davmail uses by default. As of davmail 6.8.0, they are:
      #        - Under "Microsoft Graph -> Delegated Permissions -> OpenId permissions"
      #          - `offline_access`
      #          - `openid`
      #          - `profile`
      #        - Under "Microsoft Graph -> Delegated Permissions -> Mail"
      #          - `Mail.ReadWrite`
      #          - `Mail.ReadWrite.Shared`
      #          - `Mail.Send`
      #        - Under "Microsoft Graph -> Delegated Permissions -> MailboxSettings"
      #          - `MailboxSettings.Read`
      #        - Under "Microsoft Graph -> Delegated Permissions -> Calendars"
      #          - `Calendars.ReadWrite`
      #        - Under "Microsoft Graph -> Delegated Permissions -> Contacts"
      #          - `Contacts.ReadWrite`
      #        - Under "Microsoft Graph -> Delegated Permissions -> Tasks"
      #          - `Tasks.ReadWrite`
      #
      # When we run davmail in headless mode, it can print the authorization URL when we run `mbsync EMAIL`.
      # It does not print the authorization URL on second attempt, so we have to restart the server if we want to retry.
      #
      # When it prints the authorization URL, it asks us to paste back the redirect URI.
      # The instruction is incorrect, it is expecting us to paste the URL decoded authorization code.
      # It is very likely that the redirect URI is URL encoded in our browser.
      # What we have to do is to copy the redirect URI to our editor,
      # manually extract the query parameter `code`, and URL decode it.
      #
      # The refresh token is stored by davmail if `davmail.oauth.persistToken=true`.
      # The refresh token is encrypted using the IMAP password as the encryption key.
      # The stored file looks like the following
      #
      # #Oauth tokens
      # #Thu Jul 09 19:01:54 HKT 2026
      # user@example.com={AES}blahblahblah
      #
      # See https://github.com/mguessan/davmail/blob/6.8.0/src/java/davmail/exchange/auth/O365Token.java#L321
      # See https://github.com/mguessan/davmail/blob/6.8.0/src/java/davmail/util/StringEncryptor.java#L40
      # See https://github.com/mguessan/davmail/blob/6.8.0/src/java/davmail/Settings.java#L647
      flavor = "davmail";
      realName = "Louis Chan";
      mu4eContextName = "hotmail";

      sopsClientID = "louischan0325_at_hotmail_dot_com/client_id";
      loginURL = "https://login.microsoftonline.com";
      redirectURI = "http://localhost/";
      tenant = "common";
      caldavPort = 1080;
      imapPort = 1143;
      ldapPort = 1389;
      popPort = 1110;
      smtpPort = 1025;
    };
  };
}
