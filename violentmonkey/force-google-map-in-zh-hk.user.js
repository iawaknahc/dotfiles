// ==UserScript==
// @name        Force Google Map in zh-HK
// @match       https://www.google.com/*
// @run-at      document-start
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
