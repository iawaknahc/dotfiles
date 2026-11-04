{
  lib,
  buildFirefoxXpiAddon,
}:
buildFirefoxXpiAddon {
  pname = "inject-jyutping";
  version = "0.5.1";
  addonId = "{6fbd51fa-0351-444c-ad29-4347c038650f}";
  url = "https://addons.mozilla.org/firefox/downloads/file/4369009/inject_jyutping-0.5.1.xpi";
  sha256 = "sha256-lCrYNYtw4PZ//K9Ru2zL/t3JJ4EWytIUYZRkK+2DAhA=";
  meta = with lib; {
    homepage = "https://github.com/CanCLID/inject-jyutping";
    description = "A browser extension that adds Cantonese pronunciation (Jyutping) on Chinese characters";
    license = licenses.bsd2;
    mozPermissions = [
      "contextMenus"
      "storage"
    ];
    platforms = platforms.all;
  };
}
