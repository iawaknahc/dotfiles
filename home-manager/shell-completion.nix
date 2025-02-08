{ pkgs, lib, ... }:
{
  # Do not use programs.carapace because we do not want to unset the shell integrations.
  home.sessionVariables = {
    "CARAPACE_BRIDGES" = "zsh,fish,bash,inshellisense";
  };
  home.packages = with pkgs; [
    inshellisense
    carapace
  ];

  programs.bash.initExtra = ''
    source <(carapace carapace)
  '';

  programs.fish.interactiveShellInit = ''
    carapace _carapace | source
  '';
  xdg.configFile."fish/completions" = {
    enable = true;
    recursive = true;
    source =
      pkgs.runCommandLocal "carapace-fish-issue-185"
        {
          buildInputs = [
            pkgs.carapace
          ];
        }
        ''
          mkdir $out
          ${pkgs.carapace}/bin/carapace --list | awk '{ print $1 }' | xargs -I{} touch $out/{}.fish
        '';
  };

  programs.nushell.extraConfig = ''
    mkdir ($nu.data-dir | path join "vendor/autoload")
    carapace _carapace nushell | save --force ($nu.data-dir | path join "vendor/autoload/carapace.nu")
  '';
  programs.zsh.initExtra = ''
    zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
    source <(carapace _carapace)
  '';
}
