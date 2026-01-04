{ pkgs, ... }:
let
  carapace = pkgs.carapace;
  # FIXME: inshellisense is builtin with NPM, it is broken as of 2026-01-04
  # inshellisense = pkgs.inshellisense;
in
{
  # Do not use programs.carapace because we do not want to unset the shell integrations.
  home.sessionVariables = {
    "CARAPACE_BRIDGES" = "zsh,fish,bash";
    # "CARAPACE_BRIDGES" = "zsh,fish,bash,inshellisense";
  };
  home.packages = [
    # inshellisense
    carapace
  ];

  programs.bash.initExtra = ''
    source <(${carapace}/bin/carapace carapace)
  '';
  programs.x-elvish.rcExtra = ''
    eval (${carapace}/bin/carapace _carapace | slurp)
  '';

  programs.fish.interactiveShellInit = ''
    ${carapace}/bin/carapace _carapace | source
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
          ${carapace}/bin/carapace --list | awk '{ print $1 }' | xargs -I{} touch $out/{}.fish
        '';
  };

  programs.nushell.extraConfig = ''
    mkdir ($nu.data-dir | path join "vendor/autoload")
    ${carapace}/bin/carapace _carapace nushell | save --force ($nu.data-dir | path join "vendor/autoload/carapace.nu")
  '';
  programs.zsh.initContent = ''
    zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
    source <(${carapace}/bin/carapace _carapace)
  '';
}
