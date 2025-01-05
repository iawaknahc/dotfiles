{
  nixpkgsHostPlatform,
  nixpkgs,
  home-manager,
  nix-darwin,
  darwin-config,
  ...
}:
{
  nixpkgs.hostPlatform = nixpkgsHostPlatform;
  system.stateVersion = 5;

  services.nix-daemon.enable = true;

  nix.channel.enable = false;

  nix.nixPath = [
    # nix repl --file <nixpkgs>
    { nixpkgs = "${nixpkgs.outPath}"; }

    # nix repl --file <home-manager>
    { home-manager = "${home-manager.outPath}"; }

    # nix repl --file <nix-darwin>
    # repl> config
    { nix-darwin = "${nix-darwin.outPath}"; }
    { inherit darwin-config; }

    # To debug the evaluated config of home-manager or nix-darwin,
    # we can load the flake in repl.
    # cd ~/dotfiles; nix repl .
  ];

  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.upgrade-nix-store-path-url = "https://install.determinate.systems/nix-upgrade/stable/universal";

  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.fish.enable = true;
  programs.fish.useBabelfish = true;

  # Use TouchID for sudo.
  security.pam.enableSudoTouchIdAuth = true;
}
