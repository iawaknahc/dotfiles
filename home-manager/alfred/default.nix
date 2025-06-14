{
  pkgs,
  config,
  ...
}:
let
  libalfred = (import ../lib/alfred.nix) { inherit pkgs; };
in
{
  alfred.configDir = "${config.home.homeDirectory}/alfred";
  alfred.sourceDir = "${config.home.homeDirectory}/dotfiles";

  alfred.sourceFile."preferences/prefs.plist".source =
    ../../alfred/Alfred.alfredpreferences/preferences/prefs.plist;
  alfred.sourceFile."preferences/features/calculator/prefs.plist".source =
    ../../alfred/Alfred.alfredpreferences/preferences/features/calculator/prefs.plist;
  alfred.sourceFile."preferences/features/clipboard/prefs.plist".source =
    ../../alfred/Alfred.alfredpreferences/preferences/features/clipboard/prefs.plist;
  alfred.sourceFile."preferences/features/contacts/email/prefs.plist".source =
    ../../alfred/Alfred.alfredpreferences/preferences/features/contacts/email/prefs.plist;
  alfred.sourceFile."preferences/features/contacts/prefs.plist".source =
    ../../alfred/Alfred.alfredpreferences/preferences/features/contacts/prefs.plist;
  alfred.sourceFile."preferences/features/defaultresults/prefs.plist".source =
    ../../alfred/Alfred.alfredpreferences/preferences/features/defaultresults/prefs.plist;
  alfred.sourceFile."preferences/features/dictionary/define/prefs.plist".source =
    ../../alfred/Alfred.alfredpreferences/preferences/features/dictionary/define/prefs.plist;
  alfred.sourceFile."preferences/features/dictionary/spell/prefs.plist".source =
    ../../alfred/Alfred.alfredpreferences/preferences/features/dictionary/spell/prefs.plist;
  alfred.sourceFile."preferences/features/filesearch/actions/prefs.plist".source =
    ../../alfred/Alfred.alfredpreferences/preferences/features/filesearch/actions/prefs.plist;
  alfred.sourceFile."preferences/features/filesearch/prefs.plist".source =
    ../../alfred/Alfred.alfredpreferences/preferences/features/filesearch/prefs.plist;
  alfred.sourceFile."preferences/features/itunes/prefs.plist".source =
    ../../alfred/Alfred.alfredpreferences/preferences/features/itunes/prefs.plist;
  alfred.sourceFile."preferences/features/system/prefs.plist".source =
    ../../alfred/Alfred.alfredpreferences/preferences/features/system/prefs.plist;
  alfred.sourceFile."preferences/features/terminal/prefs.plist".source =
    ../../alfred/Alfred.alfredpreferences/preferences/features/terminal/prefs.plist;
  alfred.sourceFile."preferences/features/websearch/prefs.plist".source =
    ../../alfred/Alfred.alfredpreferences/preferences/features/websearch/prefs.plist;

  alfred.sourceFile."workflows/user.workflow.00000000-0000-0000-00000000000000001/prefs.plist".source =
    ../../alfred/Alfred.alfredpreferences/workflows/user.workflow.00000000-0000-0000-00000000000000001/prefs.plist;
  alfred.storeFile."workflows/user.workflow.00000000-0000-0000-00000000000000001".source =
    pkgs.stdenv.mkDerivation
      rec {
        pname = "alfred-workflow-conv";
        version = "2025.1";

        src = pkgs.fetchFromGitHub {
          owner = "alfredapp";
          repo = "unit-converter-workflow";
          rev = "${version}";
          hash = "sha256-93o4xis86Z06yMREIwU3uhoYWaeWle9Lv7zVFb6QiyY=";
        };

        installPhase = ''
          mkdir $out
          cp -R ./Workflow/. $out/
        '';
      };

  alfred.sourceFile."workflows/user.workflow.00000000-0000-0000000000000000000002/prefs.plist".source =
    ../../alfred/Alfred.alfredpreferences/workflows/user.workflow.00000000-0000-0000-00000000000000002/prefs.plist;
  alfred.storeFile."workflows/user.workflow.00000000-0000-0000-00000000000000002".source =
    pkgs.stdenv.mkDerivation
      rec {
        pname = "alfred-workflow-cur";
        version = "2025.2";

        src = pkgs.fetchFromGitHub {
          owner = "alfredapp";
          repo = "currency-converter-workflow";
          rev = "${version}";
          hash = "sha256-142e1KZ58+cEBxJGq/W8JElemGgXTHEP0PTbsOV11F0=";
        };

        installPhase = ''
          mkdir $out
          cp -R ./Workflow/. $out/
        '';
      };

  alfred.storeFile."workflows/user.workflow.00000000-0000-0000-00000000000000003/info.plist".source =
    (
      libalfred.scriptFilter {
        bundleid = "testing";
        keyword = "uuid";
        scriptfile = pkgs.writeScript "uuid.sh" ''
          #!/bin/sh
          ${pkgs.python3}/bin/python3 ${./uuid.py} "$@"
        '';
        universalaction_uid = "2B1A7F61-7082-4D46-9787-A4A95F56D698";
        scriptfilter_uid = "EB607327-7572-4C33-B268-1C5DA9E810C5";
        clipboard_uid = "EF972F30-10F4-4635-89FD-0EB2D2C537E6";
      }
    );
}
