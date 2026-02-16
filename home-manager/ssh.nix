{ pkgs, lib, ... }:
{
  programs.ssh.enable = true;
  programs.ssh.package = pkgs.openssh;
  programs.ssh.enableDefaultConfig = false;
  home.file.".ssh/gpg-keygrip-872696EE25796294DD3A8FEDD7BCC1000547C307.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID10oX/o5t2FBc/DYIQMLqpmUYzFMiGebCtYCG0B1ik+ openpgp:0x5B63D933
  '';

  programs.ssh.matchBlocks."*" = {
    identitiesOnly = true;
    identityAgent = "~/.gnupg/S.gpg-agent.ssh";
    identityFile = "~/.ssh/gpg-keygrip-872696EE25796294DD3A8FEDD7BCC1000547C307.pub";
  };

  programs.ssh.matchBlocks."home-openwrt router 192.168.1.1" = lib.hm.dag.entryAfter [ "*" ] {
    hostname = "home-openwrt.tail78d407.ts.net";
    user = "root";
  };

  programs.ssh.matchBlocks."nas" = lib.hm.dag.entryAfter [ "*" ] {
    hostname = "nas.tail78d407.ts.net";
    user = "nixos";
    sendEnv = [ "LS_COLORS" ];
  };
}
