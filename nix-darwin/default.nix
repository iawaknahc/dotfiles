{
  config = {
    system.stateVersion = 6;
  };
  imports = [
    ./nix.nix
    ./shell.nix
    ./environment-variables.nix
    ./pam.nix
    ./_10_0_2_2.nix
  ];
}
