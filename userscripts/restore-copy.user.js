// ==UserScript==
// @name        Restore copy on annoying websites
// @namespace   iawaknahc
// @match       https://www.hk01.com/*
// @run-at      document-start
// @require https://cdn.jsdelivr.net/combine/npm/@violentmonkey/dom@2,npm/@violentmonkey/ui@0.7
// @require https://cdn.jsdelivr.net/npm/@violentmonkey/shortcut@1
// ==/UserScript==

(() => {
function copy(e) {
  e.stopPropagation();
}
document.addEventListener("copy", copy, { capture: true });
})()
