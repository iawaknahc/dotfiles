// ==UserScript==
// @name        Force Wikipedia in zh-HK
// @namespace   iawaknahc
// @match       https://zh.wikipedia.org/*
// @run-at      document-start
// @require https://cdn.jsdelivr.net/combine/npm/@violentmonkey/dom@2,npm/@violentmonkey/ui@0.7
// @require https://cdn.jsdelivr.net/npm/@violentmonkey/shortcut@1
// ==/UserScript==

(() => {
  const url = new URL(window.location.href);
  const regexp = new RegExp("^/wiki/(.*)", "");
  const replacement = "/zh-hk/$1";

  if (regexp.test(url.pathname)) {
    url.pathname = url.pathname.replace(regexp, replacement);
    window.location = url.toString();
  }
})()
