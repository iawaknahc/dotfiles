{ pkgs, ... }:
{
  # We use chezmoi to manage the configuration.
  # home-manager (or Nix) is used to install workflows.

  xdg.configFile."alfred/Alfred.alfredpreferences/workflows/user.workflow.00000000-0000-0000-00000000000000001" =
    {
      recursive = true;
      source = pkgs.stdenv.mkDerivation rec {
        pname = "alfred-workflow-conv";
        version = "2025.1";

        src = pkgs.fetchFromGitHub {
          owner = "alfredapp";
          repo = "unit-converter-workflow";
          rev = "${version}";
          hash = "sha256-93o4xis86Z06yMREIwU3uhoYWaeWle9Lv7zVFb6QiyY=";
        };

        buildPhase = ''
          # It is observed that Alfred will actually change this file when configuration of this workflow is changed in the GUI.
          # Thus remove this file from the derivation and manage it with chezmoi.
          rm ./Workflow/info.plist
        '';

        installPhase = ''
          mkdir $out
          cp -R ./Workflow/. $out/
        '';
      };
    };
}
