// ==UserScript==
// @name         Restore copy on annoying websites
// @match        https://www.hk01.com/*
// @match        https://hk.on.cc/*
// @run-at       document-start
// @grant        none
// @inject-into  content
// ==/UserScript==

(() => {
function copy(e) {
  e.stopPropagation();
}
document.addEventListener("copy", copy, { capture: true });
})()
