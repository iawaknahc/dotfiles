{
  imports = [ ./impl.nix ];

  config = {
    email.enable = true;

    email.accounts."louischan0325@gmail.com" = {
      primary = true;
      flavor = "gmail.com";
      realName = "Louis Chan";
      mu4eContextName = "personal";

      sopsClientID = "pizauth/google/client_id";
      sopsClientSecret = "pizauth/google/client_secret";
    };

    email.accounts."louischan0325@hotmail.com" = {
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
      enable = false;
      flavor = "outlook.office365.com";
      realName = "Louis Chan";

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
      sopsClientID = "pizauth/azure/client_id";
      sopsClientSecret = "pizauth/azure/client_secret";
    };
  };
}
