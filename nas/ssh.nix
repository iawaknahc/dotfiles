{ ... }:
{
  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
    AcceptEnv = [ "LS_COLORS" ];
  };
  # By default, these are true, causing LS_COLORS set by SSH client to be overridden.
  programs.bash.enableLsColors = false;
  programs.zsh.enableLsColors = false;
}
