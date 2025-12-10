// ==UserScript==
// @name          Restore copy on annoying websites
// @match         https://*/*
// @exclude-match https://docs.google.com/*
// @run-at        document-start
// ==/UserScript==

// We have to exclude docs.google.com, otherwise copy is broken in Google Docs.

(() => {
  function copy(e) {
    e.stopPropagation();
  }
  document.addEventListener("copy", copy, { capture: true });
})();
