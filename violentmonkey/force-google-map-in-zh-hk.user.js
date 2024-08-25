// ==UserScript==
// @name        Force Google Map in zh-HK
// @namespace   iawaknahc
// @match       https://www.google.com/*
// @run-at      document-start
// @require https://cdn.jsdelivr.net/combine/npm/@violentmonkey/dom@2,npm/@violentmonkey/ui@0.7
// @require https://cdn.jsdelivr.net/npm/@violentmonkey/shortcut@1
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
})()
