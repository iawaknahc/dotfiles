// ==UserScript==
// @name        Force Google Map in zh-HK
// @version     0.1.0
// @match       https://www.google.com/*
// @run-at      document-start
// @downloadURL https://raw.githubusercontent.com/iawaknahc/dotfiles/refs/heads/master/violentmonkey/force-google-map-in-zh-hk.user.js
// ==/UserScript==

(() => {
  const url = new URL(window.location.href);
  const isGoogleMap = url.pathname.startsWith("/maps");
  const isMissingHL = !url.searchParams.has("hl");
  if (isGoogleMap && isMissingHL) {
    const params = url.searchParams;
    params.set("hl", "zh-HK");
    url.search = "?" + params.toString();
    window.location = url.toString();
  }
})();
