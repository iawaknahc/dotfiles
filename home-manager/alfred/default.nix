{
  pkgs,
  config,
  ...
}:
let
  python3 = pkgs.python3.withPackages (
    python3-pkgs: with python3-pkgs; [
      pyperclip
    ]
  );
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

  alfred.sourceFile."workflows/user.workflow.00000000-0000-0000-00000000000000002/prefs.plist".source =
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

  home.packages = with pkgs; [
    (writeShellScriptBin "alfred-workflow-uuid.py" ''
      ${python3}/bin/python3 ${./uuid.py} "$@"
    '')
    (writeShellScriptBin "alfred-workflow-godoc.py" ''
      ${python3}/bin/python3 ${./godoc.py} "$@"
    '')
  ];
  # uuid
  alfred.sourceFile."workflows/user.workflow.7268443B-96A6-42D5-A0D4-9826610CCEF7/info.plist".source =
    ../../alfred/Alfred.alfredpreferences/workflows/user.workflow.7268443B-96A6-42D5-A0D4-9826610CCEF7/info.plist;
  # godoc
  alfred.sourceFile."workflows/user.workflow.5351E82E-6439-4799-B082-F811E01191DE/info.plist".source =
    ../../alfred/Alfred.alfredpreferences/workflows/user.workflow.5351E82E-6439-4799-B082-F811E01191DE/info.plist;
}
