{ pkgs, lib, ... }:
let
  _1password = "d634138d-c276-4fc8-924b-40a0ea21d284";
  stylus = "7a7a4a92-a2a0-41d1-9fd7-1e92480d612d";
  violentmonkey = "aecec67f-0d10-4fa7-b7c7-609a2db280cf";
  libstylus = import ./libstylus.nix { inherit lib; };
  libviolentmonkey = import ./libviolentmonkey.nix { inherit lib; };

  listdir = path: builtins.map (s: path + ("/" + s)) (builtins.attrNames (builtins.readDir path));
in
{
  programs.firefox.enable = true;
  # It takes so long to compile pkgs.firefox from scratch.
  # So we use pkgs.firefox-bin instead.
  #
  # See the below comment on pkgs.firefox and pkgs.firefox-bin.
  programs.firefox.package = pkgs.firefox-bin;

  programs.firefox.profiles.default.extensions.packages = [
    # 1Password requires signed browser apps.
    # https://support.1password.com/additional-browsers/?mac
    #
    # pkgs.firefox is not signed.
    # pkgs.firefox-bin just fail to start without any error.
    #
    # Thus, the best we can have to just use home-manager to manage
    # the Firefox profile.
    # Firefox itself has to be installed with .dmg.
    pkgs.nur.repos.rycee.firefox-addons.onepassword-password-manager
    pkgs.nur.repos.rycee.firefox-addons.web-clipper-obsidian
    pkgs.nur.repos.rycee.firefox-addons.violentmonkey
    pkgs.nur.repos.rycee.firefox-addons.stylus
    pkgs.nur.repos.natsukium.my-firefox-addons.adguard-adblocker
  ];

  # How does this work?
  # When we specify any settings of any extensions,
  # home-manager set extensions.webextensions.ExtensionStorageIDB.enabled to false.
  # https://github.com/nix-community/home-manager/blob/release-25.05/modules/programs/firefox/mkFirefoxModule.nix#L91
  #
  # This turns off IndexedDB storage of extension,
  # instead extension storage is now <profile>/browser-extension-data/<extension-id>/storage.js
  # storage.js is just a JSON file.
  # These JSON files are captured by tweaking the extension with GUI,
  # stripping any sensitive information.
  #
  # programs.firefox.profiles.default.extensions.force is a flag that
  # home-manager asks us to set to true to acknowledge that
  # every time home-manager switch is taken, the storage.js will be overwritten.
  programs.firefox.profiles.default.extensions.force = true;
  programs.firefox.profiles.default.extensions.settings."adguardadblocker@adguard.com".settings =
    builtins.fromJSON (builtins.readFile ./adguard.json);
  programs.firefox.profiles.default.extensions.settings."{${_1password}}".settings =
    builtins.fromJSON (builtins.readFile ./1password.json);
  programs.firefox.profiles.default.extensions.settings."{${stylus}}".settings =
    libstylus.mkSettings (listdir ./stylus);
  programs.firefox.profiles.default.extensions.settings."{${violentmonkey}}".settings =
    libviolentmonkey.mkSettings (listdir ./violentmonkey);

  programs.firefox.profiles.default.settings = {
    # Automatically enable installed add-ons.
    "extensions.autoDisableScopes" = 0;

    # Hide the warning in about:config
    "browser.aboutConfig.showWarning" = false;

    # Restore previous session.
    "browser.startup.page" = 3;
    # Do not warn on quit with keyboard shortcut.
    "browser.warnOnQuitShortcut" = false;

    # Show a blank page for new tab.
    "browser.newtabpage.enabled" = false;

    # Show a blank page for home.
    "browser.startup.homepage" = "chrome://browser/content/blanktab.html";

    # HTTPS only.
    "dom.security.https_only_mode" = true;

    # Enable Vertical tabs.
    "sidebar.verticalTabs" = true;

    # Hide bookmark toolbar.
    "browser.toolbars.bookmarks.visibility" = "never";

    # Never translate the languages I speak.
    "browser.translations.neverTranslateLanguages" = "en,ja,zh-Hans";

    # Customize the UI.
    "browser.uiCustomization.state" = {
      placements = {
        "widget-overflow-fixed-list" = [ ];
        "unified-extensions-area" = [ ];
        "nav-bar" = [
          "back-button"
          "forward-button"
          "vertical-spacer"
          "urlbar-container"
          "downloads-button"
          "_${_1password}_-browser-action"
          "adguardadblocker_adguard_com-browser-action"
          "clipper_obsidian_md-browser-action"
          "_${violentmonkey}_-browser-action"
          "_${stylus}_-browser-action"
          "unified-extensions-button"
        ];
        TabsToolbar = [ ];
        "vertical-tabs" = [
          "tabbrowser-tabs"
        ];
        PersonalToolbar = [
          "import-button"
          "personal-bookmarks"
        ];
      };
      seen = [
        "developer-button"
        "screenshot-button"
        "adguardadblocker_adguard_com-browser-action"
        "clipper_obsidian_md-browser-action"
        "_${_1password}_-browser-action"
        "_${violentmonkey}_-browser-action"
        "_${stylus}_-browser-action"
      ];
      dirtyAreaCache = [
        "nav-bar"
        "vertical-tabs"
        "PersonalToolbar"
        "TabsToolbar"
        "unified-extensions-area"
      ];
      currentVersion = 23;
      newElementCount = 6;
    };
  };
}
