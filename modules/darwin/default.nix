{
  config = {
    system.stateVersion = 6;
    # See https://emudhra.we-have-a-problem.com/
    security.pki.caCertificateBlacklist = [
      "Comodo AAA Services root"
      "emSign ECC Root CA - G3"
    ];
  };
  imports = [
    ./nix.nix
    ./shell.nix
    ./environment-variables.nix
    ./pam.nix
    ./_10_0_2_2.nix
    ./homebrew.nix
    ./karabiner.nix
  ];
}
