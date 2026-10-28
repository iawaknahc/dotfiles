// ==UserScript==
// @name        Extract Google Map Place
// @match       https://www.google.com/*
// @run-at      document-idle
// @grant       GM_registerMenuCommand
// @grant       GM_setClipboard
// @require     https://cdn.jsdelivr.net/npm/@violentmonkey/shortcut@1.4.4
// ==/UserScript==

(() => {
  const doWork = async () => {
    const url = window.location.href;

    const titleElement = document.querySelector("h1");
    if (titleElement == null) {
      window.alert("You are probably not viewing a place.");
      return;
    }
    const title = titleElement.innerText;

    const addressElement = document.querySelector("[data-item-id='address']");
    if (addressElement == null) {
      window.alert("You are probably not viewing a place.");
      return;
    }
    const addressAttribute = addressElement.getAttribute("aria-label");
    if (addressAttribute == null) {
      window.alert("You are probably not viewing a place.");
      return;
    }

    const formattedAddress = addressAttribute.trim().replace(/^地址: /, "");

    GM_setClipboard(
      JSON.stringify(
        {
          url,
          title,
          formattedAddress,
        },
        null,
        2,
      ),
      "text/plain",
    );
    window.alert("Copied to clipboard");
  };

  const shortcut = "c-c c-c";
  const name = "Extract Google Map Place to JSON";
  const handler = () => {
    doWork().catch((e) => console.error(e));
  };

  // See https://violentmonkey.github.io/guide/keyboard-shortcuts/#shortcut-for-menu-command
  const menuName = `${name} (${VM.shortcut.reprShortcut(shortcut)})`;
  console.log(`Registering ${menuName}`);
  GM_registerMenuCommand(menuName, handler);
  // It is a known issue that if the map is focused, the shortcut will not work.
  // You have to focus on an ordinary HTML element by clicking to work around the issue.
  VM.shortcut.register(shortcut, handler);
})();
