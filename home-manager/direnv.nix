{
  config,
  lib,
  ...
}:
{
  home.packages = [
    config.programs.direnv.package
    config.programs.direnv.nix-direnv.package
  ];
  xdg.configFile."direnv/lib/hm-nix-direnv.sh" = {
    enable = true;
    source = "${config.programs.direnv.nix-direnv.package}/share/nix-direnv/direnvrc";
  };

  programs.bash.initExtra = lib.mkAfter ''
    eval "$(${config.programs.direnv.package}/bin/direnv hook bash)"
  '';

  programs.x-elvish.rcExtra = lib.mkAfter ''
    eval (${config.programs.direnv.package}/bin/direnv hook elvish | slurp)
  '';

  programs.fish.interactiveShellInit = lib.mkAfter ''
    ${config.programs.direnv.package}/bin/direnv hook fish | source
  '';

  programs.nushell.extraConfig = lib.mkAfter ''
    $env.config = ($env.config | upsert hooks.env_change.PWD {|config|
      let val = ($config | get -i hooks.env_change.PWD)
      if $val == null {
        $val | append {|| ${config.programs.direnv.package}/bin/direnv export json | from json | default {} | load-env }
      } else {
        [
          {|| ${config.programs.direnv.package}/bin/direnv export json | from json | default {} | load-env }
        ]
      }
    })
  '';

  programs.zsh.initExtra = lib.mkAfter ''
    eval "$(${config.programs.direnv.package}/bin/direnv hook zsh)"
  '';
}
