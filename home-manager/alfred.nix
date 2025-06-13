{
  config,
  ...
}:
{
  alfred.configDir = "${config.home.homeDirectory}/alfred";
  alfred.sourceDir = "${config.home.homeDirectory}/dotfiles";

  alfred.sourceFile."preferences/prefs.plist".source =
    ../alfred/Alfred.alfredpreferences/preferences/prefs.plist;
  alfred.sourceFile."preferences/features/calculator/prefs.plist".source =
    ../alfred/Alfred.alfredpreferences/preferences/features/calculator/prefs.plist;
  alfred.sourceFile."preferences/features/clipboard/prefs.plist".source =
    ../alfred/Alfred.alfredpreferences/preferences/features/clipboard/prefs.plist;
  alfred.sourceFile."preferences/features/contacts/email/prefs.plist".source =
    ../alfred/Alfred.alfredpreferences/preferences/features/contacts/email/prefs.plist;
  alfred.sourceFile."preferences/features/contacts/prefs.plist".source =
    ../alfred/Alfred.alfredpreferences/preferences/features/contacts/prefs.plist;
  alfred.sourceFile."preferences/features/defaultresults/prefs.plist".source =
    ../alfred/Alfred.alfredpreferences/preferences/features/defaultresults/prefs.plist;
  alfred.sourceFile."preferences/features/dictionary/define/prefs.plist".source =
    ../alfred/Alfred.alfredpreferences/preferences/features/dictionary/define/prefs.plist;
  alfred.sourceFile."preferences/features/dictionary/spell/prefs.plist".source =
    ../alfred/Alfred.alfredpreferences/preferences/features/dictionary/spell/prefs.plist;
  alfred.sourceFile."preferences/features/filesearch/actions/prefs.plist".source =
    ../alfred/Alfred.alfredpreferences/preferences/features/filesearch/actions/prefs.plist;
  alfred.sourceFile."preferences/features/filesearch/prefs.plist".source =
    ../alfred/Alfred.alfredpreferences/preferences/features/filesearch/prefs.plist;
  alfred.sourceFile."preferences/features/itunes/prefs.plist".source =
    ../alfred/Alfred.alfredpreferences/preferences/features/itunes/prefs.plist;
  alfred.sourceFile."preferences/features/system/prefs.plist".source =
    ../alfred/Alfred.alfredpreferences/preferences/features/system/prefs.plist;
  alfred.sourceFile."preferences/features/terminal/prefs.plist".source =
    ../alfred/Alfred.alfredpreferences/preferences/features/terminal/prefs.plist;
  alfred.sourceFile."preferences/features/websearch/prefs.plist".source =
    ../alfred/Alfred.alfredpreferences/preferences/features/websearch/prefs.plist;
}
