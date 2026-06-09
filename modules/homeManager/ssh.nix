{ pkgs, lib, ... }:
{
  programs.ssh.enable = true;
  programs.ssh.package = pkgs.openssh;
  programs.ssh.enableDefaultConfig = false;
  home.file.".ssh/gpg-keygrip-872696EE25796294DD3A8FEDD7BCC1000547C307.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID10oX/o5t2FBc/DYIQMLqpmUYzFMiGebCtYCG0B1ik+ openpgp:0x5B63D933
  '';

  programs.ssh.settings."*" = {
    IdentitiesOnly = true;
    IdentityAgent = "~/.gnupg/S.gpg-agent.ssh";
    IdentityFile = "~/.ssh/gpg-keygrip-872696EE25796294DD3A8FEDD7BCC1000547C307.pub";
  };

  programs.ssh.settings."home-openwrt router 192.168.1.1" = lib.hm.dag.entryAfter [ "*" ] {
    Hostname = "home-openwrt.tail78d407.ts.net";
    User = "root";
  };

  programs.ssh.settings."nas" = lib.hm.dag.entryAfter [ "*" ] {
    Hostname = "nas.tail78d407.ts.net";
    User = "nixos";
    SendEnv = [ "LS_COLORS" ];
  };
}
