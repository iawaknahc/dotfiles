// ==UserScript==
// @name        Force Wikipedia in zh-HK
// @version     0.1.0
// @match       https://zh.wikipedia.org/*
// @run-at      document-start
// ==/UserScript==

(() => {
  const url = new URL(window.location.href);
  const regexp = new RegExp("^/wiki/(.*)", "");
  const replacement = "/zh-hk/$1";

  if (regexp.test(url.pathname)) {
    url.pathname = url.pathname.replace(regexp, replacement);
    window.location = url.toString();
  }
})();
