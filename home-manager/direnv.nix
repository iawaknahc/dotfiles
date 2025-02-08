{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    direnv
    nix-direnv
  ];
  xdg.configFile."direnv/lib/hm-nix-direnv.sh" = {
    enable = true;
    source = "${pkgs.nix-direnv}/share/nix-direnv/direnvrc";
  };

  programs.bash.initExtra = lib.mkAfter ''
    eval "$(direnv hook bash)"
  '';

  programs.fish.interactiveShellInit = lib.mkAfter ''
    direnv hook fish | source
  '';

  programs.nushell.extraConfig = lib.mkAfter ''
    $env.config = ($env.config | upsert hooks.env_change.PWD {|config|
      let val = ($config | get -i hooks.env_change.PWD)
      if $val == null {
        $val | append {|| direnv export json | from json | default {} | load-env }
      } else {
        [
          {|| direnv export json | from json | default {} | load-env }
        ]
      }
    })
  '';

  programs.zsh.initExtra = lib.mkAfter ''
    eval "$(direnv hook zsh)"
  '';
}
