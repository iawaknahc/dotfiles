{ pkgs, ... }:
{
  # Do not use programs.starship because we do not want to unset the shell integrations.
  home.packages = with pkgs; [
    starship
  ];
  xdg.configFile."starship.toml" = {
    enable = true;
    source = ../.config/starship.toml;
  };
  programs.bash.initExtra = ''
    eval "$(starship init bash)"
  '';
  programs.x-elvish.rcExtra = ''
    eval (starship init elvish)
  '';
  programs.fish.interactiveShellInit = ''
    starship init fish | source
  '';
  programs.nushell.extraConfig = ''
    mkdir ($nu.data-dir | path join "vendor/autoload")
    starship init nu | save --force ($nu.data-dir | path join "vendor/autoload/starship.nu")
  '';
  programs.zsh.initExtra = ''
    eval "$(starship init zsh)"
  '';
}
