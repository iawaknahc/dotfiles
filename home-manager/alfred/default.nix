{
  pkgs,
  config,
  ...
}:
{
  alfred.enable = true;
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

  alfred.storeFile."workflows/user.workflow.00000000-0000-0000-00000000000000003".source =
    pkgs.stdenv.mkDerivation
      rec {
        pname = "alfred-workflow-switch-appearance";
        version = "2024.1";

        src = pkgs.fetchFromGitHub {
          owner = "alfredapp";
          repo = "switch-appearance-workflow";
          rev = "${version}";
          hash = "sha256-OBoZrJCHnLaZ0cTHGBfh6RPySwcSDLQUlp/2eexzi14=";
        };

        installPhase = ''
          mkdir $out
          cp -R ./Workflow/. $out/
        '';
      };

  home.packages = [
    (pkgs.writeShellScriptBin "alfred-workflow-uuid.py" ''
      ${pkgs.mypython}/bin/python3 ${./uuid.py} "$@"
    '')
    (pkgs.writeShellScriptBin "alfred-workflow-godoc.py" ''
      export HS=${pkgs.hs}/bin/hs
      export HS_SCRIPT=${../../.hammerspoon/get_browser_url.lua}
      ${pkgs.mypython}/bin/python3 ${./godoc.py} "$@"
    '')
    (pkgs.writeShellScriptBin "alfred-workflow-t.py" ''
      # Force zoneinfo to use tzdata
      # https://docs.python.org/3/library/zoneinfo.html#envvar-PYTHONTZPATH
      export PYTHONTZPATH=""
      export FZF=${pkgs.fzf}/bin/fzf
      ${pkgs.mypython}/bin/python3 ${./t.py} "$@"
    '')
    (pkgs.writeShellScriptBin "alfred-workflow-u.py" ''
      ${pkgs.mypython}/bin/python3 ${./u.py} "$@"
    '')
    (pkgs.writeShellScriptBin "alfred-workflow-cj.py" ''
      ${pkgs.mypython}/bin/python3 ${./cj.py} "$@"
    '')
    (pkgs.writeShellScriptBin "alfred-workflow-s2t.py" ''
      ${pkgs.mypython}/bin/python3 ${./s2t.py} "$@"
    '')
    (pkgs.writeShellScriptBin "alfred-workflow-t2s.py" ''
      ${pkgs.mypython}/bin/python3 ${./t2s.py} "$@"
    '')
    (pkgs.writeShellScriptBin "alfred-workflow-yue.py" ''
      ${pkgs.mypython}/bin/python3 ${./yue.py} "$@"
    '')
    (pkgs.writeShellScriptBin "alfred-workflow-cur.py" ''
      ${pkgs.mypython}/bin/python3 ${./cur.py} "$@"
    '')
  ];
  # uuid
  alfred.sourceFile."workflows/user.workflow.7268443B-96A6-42D5-A0D4-9826610CCEF7/info.plist".source =
    ../../alfred/Alfred.alfredpreferences/workflows/user.workflow.7268443B-96A6-42D5-A0D4-9826610CCEF7/info.plist;
  # godoc
  alfred.sourceFile."workflows/user.workflow.5351E82E-6439-4799-B082-F811E01191DE/info.plist".source =
    ../../alfred/Alfred.alfredpreferences/workflows/user.workflow.5351E82E-6439-4799-B082-F811E01191DE/info.plist;
  # t
  alfred.sourceFile."workflows/user.workflow.B942CA66-01AB-46C7-8F96-07F485960CC8/info.plist".source =
    ../../alfred/Alfred.alfredpreferences/workflows/user.workflow.B942CA66-01AB-46C7-8F96-07F485960CC8/info.plist;
  # u
  alfred.sourceFile."workflows/user.workflow.9CCC68D8-1EA4-4F54-AA4A-8A945A276500/info.plist".source =
    ../../alfred/Alfred.alfredpreferences/workflows/user.workflow.9CCC68D8-1EA4-4F54-AA4A-8A945A276500/info.plist;
  # cj
  alfred.sourceFile."workflows/user.workflow.AFD896F9-B242-44CB-8211-4F4A5A70090F/info.plist".source =
    ../../alfred/Alfred.alfredpreferences/workflows/user.workflow.AFD896F9-B242-44CB-8211-4F4A5A70090F/info.plist;
  # s2t
  alfred.sourceFile."workflows/user.workflow.56CC1B97-98F6-40DA-AF3E-6FDFFE7F9EE6/info.plist".source =
    ../../alfred/Alfred.alfredpreferences/workflows/user.workflow.56CC1B97-98F6-40DA-AF3E-6FDFFE7F9EE6/info.plist;
  # t2s
  alfred.sourceFile."workflows/user.workflow.39E79EC6-CF91-44B6-91C1-75DD2E52C5ED/info.plist".source =
    ../../alfred/Alfred.alfredpreferences/workflows/user.workflow.39E79EC6-CF91-44B6-91C1-75DD2E52C5ED/info.plist;
  # yue
  alfred.sourceFile."workflows/user.workflow.74EF11C7-1F21-4FAA-89A0-9E32669B7A30/info.plist".source =
    ../../alfred/Alfred.alfredpreferences/workflows/user.workflow.74EF11C7-1F21-4FAA-89A0-9E32669B7A30/info.plist;
  # cur
  alfred.sourceFile."workflows/user.workflow.E83534A4-975A-49E0-9482-F498EE56F0F8/info.plist".source =
    ../../alfred/Alfred.alfredpreferences/workflows/user.workflow.E83534A4-975A-49E0-9482-F498EE56F0F8/info.plist;
}
