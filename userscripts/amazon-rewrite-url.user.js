// ==UserScript==
// @name        amazon-rewrite-url
// @namespace   iawaknahc
// @match       https://www.amazon.com/*
// @run-at      document-idle
// @require https://cdn.jsdelivr.net/combine/npm/@violentmonkey/dom@2,npm/@violentmonkey/ui@0.7
// @require https://cdn.jsdelivr.net/npm/@violentmonkey/shortcut@1
// ==/UserScript==

VM.observe(document.body, () => {
  const regex = new RegExp("^https://www\\.amazon\\.com/([^/]*)/dp/([^/]*)/.*$", '');
  const replacement = "https://www.amazon.com/$1/dp/$2";

  const anchors = document.querySelectorAll('a[href]');
  for (const a of anchors) {
    if (regex.test(a.href)) {
      a.href = a.href.replace(regex, replacement);
    }
  }
});
