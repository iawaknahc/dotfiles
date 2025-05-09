// ==UserScript==
// @name        Restore copy on annoying websites
// @version     0.1.0
// @match       https://www.hk01.com/*
// @match       https://hk.on.cc/*
// @run-at      document-start
// @downloadURL https://raw.githubusercontent.com/iawaknahc/dotfiles/refs/heads/master/violentmonkey/restore-copy.user.js
// ==/UserScript==

(() => {
  function copy(e) {
    e.stopPropagation();
  }
  document.addEventListener("copy", copy, { capture: true });
})();
