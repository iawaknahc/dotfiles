{ config, ... }:
{
  # Do not use programs.starship because we do not want to unset the shell integrations.
  home.packages = [
    config.programs.starship.package
  ];
  xdg.configFile."starship.toml" = {
    enable = true;
    source = ../.config/starship.toml;
  };
  programs.bash.initExtra = ''
    eval "$(${config.programs.starship.package}/bin/starship init bash)"
  '';
  programs.x-elvish.rcExtra = ''
    eval (${config.programs.starship.package}/bin/starship init elvish)
  '';
  programs.fish.interactiveShellInit = ''
    ${config.programs.starship.package}/bin/starship init fish | source
  '';
  programs.nushell.extraConfig = ''
    mkdir ($nu.data-dir | path join "vendor/autoload")
    ${config.programs.starship.package}/bin/starship init nu | save --force ($nu.data-dir | path join "vendor/autoload/starship.nu")
  '';
  programs.zsh.initExtra = ''
    eval "$(${config.programs.starship.package}/bin/starship init zsh)"
  '';
}
