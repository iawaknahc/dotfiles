{
  config = {
    system.stateVersion = 6;
  };
  imports = [
    ./nix-darwin/nix.nix
    ./nix-darwin/shell.nix
    ./nix-darwin/environment-variables.nix
    ./nix-darwin/pam.nix
    ./nix-darwin/_10_0_2_2.nix
  ];
}
