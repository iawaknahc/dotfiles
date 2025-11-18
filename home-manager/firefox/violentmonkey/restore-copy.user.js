// ==UserScript==
// @name        Restore copy on annoying websites
// @match       https://*/*
// @run-at      document-start
// ==/UserScript==

(() => {
  function copy(e) {
    e.stopPropagation();
  }
  document.addEventListener("copy", copy, { capture: true });
})();
