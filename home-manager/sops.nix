{
  pkgs,
  config,
  ...
}:
{
  home.packages = with pkgs; [ sops ];
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.gnupg.home = config.programs.gpg.homedir;

  # The secrets are written to $HOME/.config/sops-nix/secrets
  # See https://github.com/Mic92/sops-nix?tab=readme-ov-file#use-with-home-manager
}
