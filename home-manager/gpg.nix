{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.gnupg
    pkgs.pinentry_mac
    pkgs.pinentry-tty
  ];
  home.activation.createGPGHomeDir =
    lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ]
      ''
        run mkdir -m700 -p $VERBOSE_ARG ${
          pkgs.lib.strings.escapeShellArgs [ "${config.programs.gpg.homedir}" ]
        }
      '';
  home.file."${config.programs.gpg.homedir}/gpg.conf" = {
    enable = true;
    source = ../.gnupg/gpg.conf;
  };
  home.file."${config.programs.gpg.homedir}/dirmngr.conf" = {
    enable = true;
    source = ../.gnupg/dirmngr.conf;
  };
  home.file."${config.programs.gpg.homedir}/gpg-agent.conf" = {
    enable = true;
    # pinentry-program accepts only absolute path.
    # See https://dev.gnupg.org/T4588
    text = ''
      pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
    '';
  };
}
