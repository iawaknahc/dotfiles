{
  config,
  pkgs,
  ...
}:
let
  pinentrymac = with pkgs; pinentry_mac;
in
{
  programs.gpg.enable = true;
  home.packages = with pkgs; [
    pinentrymac
    pinentry-tty
    yubikey-manager
  ];

  programs.gpg.settings = {
    # Make it verbose by default. Use --no-verbose to revert.
    verbose = true;
    # Change the default output format to ASCII armored
    armor = true;
    # DO NOT specify with-fingerprint as that will cause gpg to
    # print the fingerprint with spaces.
    # It makes copying hard.
    with-fingerprint = false;
    # Always show the fingerprint of a subkey.
    with-subkey-fingerprints = true;
    # Always show the keygrip.
    with-keygrip = true;

    # Change some defaults implied by programs.gpg.settings.
    personal-cipher-preferences = "AES256";
    personal-digest-preferences = "SHA256";
    personal-compress-preferences = "ZIP Uncompressed";
    default-preference-list = "SHA256 AES256 ZIP Uncompressed";
    cert-digest-algo = "SHA256";
    s2k-digest-algo = "SHA256";
    s2k-cipher-algo = "AES256";

    # Show expired uids and subkeys, otherwise it is hard to tell they were there.
    list-options = "show-uid-validity,show-unusable-uids,show-unusable-subkeys";
    verify-options = "show-uid-validity,show-unusable-uids";
  };

  home.file."${config.programs.gpg.homedir}/dirmngr.conf".source = ../.gnupg/dirmngr.conf;
  home.file."${config.programs.gpg.homedir}/gpg-agent.conf".text = ''
    # pinentry-program accepts only absolute path.
    # See https://dev.gnupg.org/T4588
    pinentry-program ${pinentrymac}/bin/pinentry-mac
  '';
}
