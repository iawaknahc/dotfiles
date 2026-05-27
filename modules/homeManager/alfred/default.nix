{
  pkgs,
  config,
  ...
}:
{
  assertions = [
    {
      assertion = config.mypython.pythonPackages.pycangjie.version == "1.5.0";
      message = "A version newer than 1.5.0 of pycangjie was released. Consider switching to it.";
    }
  ];

  mypython.packages = [
    (
      python-pkgs: with python-pkgs; [
        opencc
        pyperclip

        # Timezone handling
        tzdata
        pytz
        tzlocal

        # The merge request was merged.
        # https://gitlab.freedesktop.org/cangjie/pycangjie/-/merge_requests/60
        (pycangjie.overrideAttrs (prev: {
          src = pkgs.fetchFromGitLab {
            domain = "gitlab.freedesktop.org";
            owner = "cangjie";
            repo = "pycangjie";
            rev = "2e743c1339dc3cb1230ae3244e120a2b32b0224a";
            hash = "sha256-/5a++Epr9gBsT6pVTRDc8PbAE8Z4hmhqcQxpam4S1qM=";
          };
        }))
      ]
    )
  ];

  alfred.enable = true;
  alfred.configDir = "${config.home.homeDirectory}/alfred";
  alfred.sourceDir = "${config.home.homeDirectory}/dotfiles";

  alfred.sourceFile."preferences/prefs.plist".source =
    ./alfred/Alfred.alfredpreferences/preferences/prefs.plist;
  alfred.sourceFile."preferences/features/calculator/prefs.plist".source =
    ./alfred/Alfred.alfredpreferences/preferences/features/calculator/prefs.plist;
  alfred.sourceFile."preferences/features/clipboard/prefs.plist".source =
    ./alfred/Alfred.alfredpreferences/preferences/features/clipboard/prefs.plist;
  alfred.sourceFile."preferences/features/contacts/email/prefs.plist".source =
    ./alfred/Alfred.alfredpreferences/preferences/features/contacts/email/prefs.plist;
  alfred.sourceFile."preferences/features/contacts/prefs.plist".source =
    ./alfred/Alfred.alfredpreferences/preferences/features/contacts/prefs.plist;
  alfred.sourceFile."preferences/features/defaultresults/prefs.plist".source =
    ./alfred/Alfred.alfredpreferences/preferences/features/defaultresults/prefs.plist;
  alfred.sourceFile."preferences/features/dictionary/define/prefs.plist".source =
    ./alfred/Alfred.alfredpreferences/preferences/features/dictionary/define/prefs.plist;
  alfred.sourceFile."preferences/features/dictionary/spell/prefs.plist".source =
    ./alfred/Alfred.alfredpreferences/preferences/features/dictionary/spell/prefs.plist;
  alfred.sourceFile."preferences/features/filesearch/actions/prefs.plist".source =
    ./alfred/Alfred.alfredpreferences/preferences/features/filesearch/actions/prefs.plist;
  alfred.sourceFile."preferences/features/filesearch/prefs.plist".source =
    ./alfred/Alfred.alfredpreferences/preferences/features/filesearch/prefs.plist;
  alfred.sourceFile."preferences/features/itunes/prefs.plist".source =
    ./alfred/Alfred.alfredpreferences/preferences/features/itunes/prefs.plist;
  alfred.sourceFile."preferences/features/system/prefs.plist".source =
    ./alfred/Alfred.alfredpreferences/preferences/features/system/prefs.plist;
  alfred.sourceFile."preferences/features/terminal/prefs.plist".source =
    ./alfred/Alfred.alfredpreferences/preferences/features/terminal/prefs.plist;
  alfred.sourceFile."preferences/features/websearch/prefs.plist".source =
    ./alfred/Alfred.alfredpreferences/preferences/features/websearch/prefs.plist;

  alfred.storeFile."workflows/user.workflow.00000000-0000-0000-00000000000000003".source =
    pkgs.alfred-workflow-switch-appearance;

  home.packages = [
    (pkgs.writeShellScriptBin "alfred-workflow-uuid.py" ''
      ${config.mypython.package}/bin/python3 ${./uuid.py} "$@"
    '')
    (pkgs.writeShellScriptBin "alfred-workflow-godoc.py" ''
      export HS=${pkgs.hammerspoon}/bin/hs
      export HS_SCRIPT=${./get_browser_url.lua}
      ${config.mypython.package}/bin/python3 ${./godoc.py} "$@"
    '')
    (pkgs.writeShellScriptBin "alfred-workflow-tz.py" ''
      # Force zoneinfo to use tzdata
      # https://docs.python.org/3/library/zoneinfo.html#envvar-PYTHONTZPATH
      export PYTHONTZPATH=""
      export FZF=${pkgs.fzf}/bin/fzf
      ${config.mypython.package}/bin/python3 ${./tz.py} "$@"
    '')
    (pkgs.writeShellScriptBin "alfred-workflow-u.py" ''
      ${config.mypython.package}/bin/python3 ${./u.py} "$@"
    '')
    (pkgs.writeShellScriptBin "alfred-workflow-cj.py" ''
      ${config.mypython.package}/bin/python3 ${./cj.py} "$@"
    '')
    (pkgs.writeShellScriptBin "alfred-workflow-s2t.py" ''
      ${config.mypython.package}/bin/python3 ${./s2t.py} "$@"
    '')
    (pkgs.writeShellScriptBin "alfred-workflow-t2s.py" ''
      ${config.mypython.package}/bin/python3 ${./t2s.py} "$@"
    '')
    (pkgs.writeShellScriptBin "alfred-workflow-yue.py" ''
      ${config.mypython.package}/bin/python3 ${./yue.py} "$@"
    '')
    (pkgs.writeShellScriptBin "alfred-workflow-nbt.py" ''
      export NUMBAT=${pkgs.numbat}/bin/numbat
      ${config.mypython.package}/bin/python3 ${./nbt.py} "$@"
    '')
  ];
  # uuid
  alfred.sourceFile."workflows/user.workflow.7268443B-96A6-42D5-A0D4-9826610CCEF7/info.plist".source =
    ./alfred/Alfred.alfredpreferences/workflows/user.workflow.7268443B-96A6-42D5-A0D4-9826610CCEF7/info.plist;
  # godoc
  alfred.sourceFile."workflows/user.workflow.5351E82E-6439-4799-B082-F811E01191DE/info.plist".source =
    ./alfred/Alfred.alfredpreferences/workflows/user.workflow.5351E82E-6439-4799-B082-F811E01191DE/info.plist;
  # tz
  alfred.sourceFile."workflows/user.workflow.B942CA66-01AB-46C7-8F96-07F485960CC8/info.plist".source =
    ./alfred/Alfred.alfredpreferences/workflows/user.workflow.B942CA66-01AB-46C7-8F96-07F485960CC8/info.plist;
  # u
  alfred.sourceFile."workflows/user.workflow.9CCC68D8-1EA4-4F54-AA4A-8A945A276500/info.plist".source =
    ./alfred/Alfred.alfredpreferences/workflows/user.workflow.9CCC68D8-1EA4-4F54-AA4A-8A945A276500/info.plist;
  # cj
  alfred.sourceFile."workflows/user.workflow.AFD896F9-B242-44CB-8211-4F4A5A70090F/info.plist".source =
    ./alfred/Alfred.alfredpreferences/workflows/user.workflow.AFD896F9-B242-44CB-8211-4F4A5A70090F/info.plist;
  # s2t
  alfred.sourceFile."workflows/user.workflow.56CC1B97-98F6-40DA-AF3E-6FDFFE7F9EE6/info.plist".source =
    ./alfred/Alfred.alfredpreferences/workflows/user.workflow.56CC1B97-98F6-40DA-AF3E-6FDFFE7F9EE6/info.plist;
  # t2s
  alfred.sourceFile."workflows/user.workflow.39E79EC6-CF91-44B6-91C1-75DD2E52C5ED/info.plist".source =
    ./alfred/Alfred.alfredpreferences/workflows/user.workflow.39E79EC6-CF91-44B6-91C1-75DD2E52C5ED/info.plist;
  # yue
  alfred.sourceFile."workflows/user.workflow.74EF11C7-1F21-4FAA-89A0-9E32669B7A30/info.plist".source =
    ./alfred/Alfred.alfredpreferences/workflows/user.workflow.74EF11C7-1F21-4FAA-89A0-9E32669B7A30/info.plist;
  # nbt
  alfred.sourceFile."workflows/user.workflow.892C4836-4E6A-4EEE-999D-8E162CF7ED62/info.plist".source =
    ./alfred/Alfred.alfredpreferences/workflows/user.workflow.892C4836-4E6A-4EEE-999D-8E162CF7ED62/info.plist;
}
