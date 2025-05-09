// ==UserScript==
// @name        amazon-rewrite-url
// @version     0.1.0
// @match       https://www.amazon.com/*
// @run-at      document-idle
// @require     https://cdn.jsdelivr.net/npm/@violentmonkey/dom@2
// @downloadURL https://raw.githubusercontent.com/iawaknahc/dotfiles/refs/heads/master/violentmonkey/amazon-rewrite-url.user.js
// ==/UserScript==

VM.observe(document.body, () => {
  const regex = new RegExp(
    "^https://www\\.amazon\\.com/([^/]*)/dp/([^/]*)/.*$",
    "",
  );
  const replacement = "https://www.amazon.com/$1/dp/$2";

  const anchors = document.querySelectorAll("a[href]");
  for (const a of anchors) {
    if (regex.test(a.href)) {
      a.href = a.href.replace(regex, replacement);
    }
  }
});
