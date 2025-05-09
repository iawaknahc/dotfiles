// ==UserScript==
// @name        webike-helper
// @version     0.1.0
// @match       https://www.webike.hk/
// @match       https://www.webike.hk/ps/*/
// @grant       GM_openInTab
// @grant       GM_getValue
// @grant       GM_deleteValue
// @grant       GM_setValue
// @grant       window.close
// @run-at      document-idle
// @require     https://cdn.jsdelivr.net/combine/npm/@violentmonkey/dom@2,npm/@violentmonkey/ui@0.7
// @require     https://cdn.jsdelivr.net/npm/@violentmonkey/shortcut@1
// @downloadURL https://raw.githubusercontent.com/iawaknahc/dotfiles/refs/heads/master/violentmonkey/webike-helper.user.js
// ==/UserScript==

function buildInputWidget() {
  const div = document.createElement("div");
  div.style.fontSize = "1rem";
  div.style.padding = "16px";
  div.style.display = "flex";
  div.style.flexDirection = "column";
  div.style.alignItems = "stretch";

  const textarea = document.createElement("textarea");
  textarea.style.width = "50vw";
  textarea.style.height = "50vh";

  const button = document.createElement("button");
  button.type = "button";
  button.textContent = "Go";
  button.style.display = "block";
  button.style.padding = "8px";

  div.appendChild(textarea);
  div.appendChild(button);

  return { div, textarea, button };
}

function buildPanel(content) {
  const panel = VM.getPanel({
    content,
  });

  panel.wrapper.style.top = "50%";
  panel.wrapper.style.left = "50%";
  panel.wrapper.style.transform = "translateX(-50%) translateY(-50%)";
  return panel;
}

function* yieldLines(lines) {
  for (const line of lines.split("\n")) {
    const trimmed = line.trim();
    if (trimmed !== "") {
      yield trimmed;
    }
  }
}

async function processLines(lines) {
  const outputRows = [];
  for (const line of yieldLines(lines)) {
    const partNumber = line;
    try {
      const result = await processPartNumber(partNumber);
      outputRows.push([result.price, result.url]);
    } catch (e) {
      switch (e.message) {
        case "timeout":
          outputRows.push(["0", "timeout"]);
          break;
        case "no_result":
          outputRows.push(["0", "no_result"]);
          break;
        case "multiple_results":
          outputRows.push(["0", "multiple_results"]);
          break;
        default:
          console.error(e);
      }
    }
  }

  const div = document.createElement("div");
  div.style.fontSize = "1rem";
  div.style.padding = "16px";
  div.style.display = "flex";
  div.style.flexDirection = "column";
  div.style.alignItems = "stretch";

  const table = document.createElement("table");
  div.appendChild(table);

  const button = document.createElement("button");
  div.appendChild(button);
  button.type = "button";
  button.textContent = "Close";
  button.style.display = "block";
  button.style.padding = "8px";

  const tbody = document.createElement("tbody");
  table.appendChild(tbody);

  for (const row of outputRows) {
    const tr = document.createElement("tr");
    tbody.appendChild(tr);
    for (const cell of row) {
      const td = document.createElement("td");
      td.textContent = cell;
      tr.appendChild(td);
    }
  }

  const panel = buildPanel(div);

  button.addEventListener("click", (e) => {
    e.preventDefault();
    e.stopPropagation();
    panel.hide();
  });

  panel.show();
}

async function processPartNumber(partNumber) {
  return new Promise((resolve, reject) => {
    const url = `https://www.webike.hk/ps/${encodeURIComponent(
      partNumber,
    )}/#!search&p.k=${encodeURIComponent(partNumber)}`;
    const tabControl = GM_openInTab(url, {
      active: false,
    });

    tabControl.onclose = () => {
      const value = GM_getValue(partNumber);
      GM_deleteValue(partNumber);
      if (value === "no_result") {
        reject(new Error("no_result"));
      } else if (value === "multiple_results") {
        reject(new Error("multiple_results"));
      } else if (typeof value === "string") {
        resolve(JSON.parse(value));
      } else {
        reject(new Error("timeout"));
      }
    };
  });
}

function setupShortcut() {
  VM.shortcut.register("c-i", () => {
    const { div, textarea, button } = buildInputWidget();

    const panel = buildPanel(div);

    button.addEventListener("click", (e) => {
      e.preventDefault();
      e.stopPropagation();

      panel.hide();

      const lines = textarea.value;
      processLines(lines);
    });

    panel.show();
  });
}

function cleanPrice(price) {
  return price.replaceAll(/[^0-9.]/g, "");
}

function cleanPartNumber(partNumber) {
  return partNumber.replaceAll(/[^-A-Za-z0-9]/g, "");
}

function isPartNumberEqual(a, b) {
  const aa = a.replaceAll(/-/g, "");
  const bb = b.replaceAll(/-/g, "");
  return aa === bb;
}

function* yieldProductItems(productList) {
  const productItems = productList.querySelectorAll(".product");
  for (const product of productItems) {
    const title = product.querySelector(".info-title").textContent;
    const price = cleanPrice(product.querySelector(".price").textContent);
    const partNumber = cleanPartNumber(
      product.querySelector(".model").textContent,
    );
    const url = product.querySelector("a[href]").href;
    yield {
      title,
      price,
      partNumber,
      url,
    };
  }
}

// Skip parts from Thai.
function noThai(productItem) {
  const { title } = productItem;
  if (/thai/i.test(title)) {
    return false;
  }
  return true;
}

function exactPartNumber(partNumber) {
  return (productItem) => {
    return isPartNumberEqual(partNumber, productItem.partNumber);
  };
}

function extractPartNumber() {
  const pathname = window.location.pathname;
  const execResult = /^\/ps\/(.*)\/$/.exec(pathname);
  const partNumber = execResult[1];
  return partNumber;
}

function processSearchResults() {
  const partNumber = extractPartNumber();

  const timeout = setTimeout(() => {
    window.close();
  }, 10000);

  const disconnect = VM.observe(document.body, () => {
    const productList = document.querySelector("ul.products-lists");
    if (productList == null) {
      return false;
    }

    let productItems = [...yieldProductItems(productList)];
    if (productItems.length === 0) {
      return false;
    }

    productItems = productItems
      .filter(noThai)
      .filter(exactPartNumber(partNumber));

    if (productItems.length === 1) {
      const hit = productItems[0];
      console.log("found 1 hit", hit);
      clearTimeout(timeout);
      GM_setValue(partNumber, JSON.stringify(hit));
      window.close();
      return true;
    } else if (productItems.length === 0) {
      console.log("found no hits");
      clearTimeout(timeout);
      GM_setValue(partNumber, "no_result");
      window.close();
      return true;
    } else {
      console.log("found multiple hits", productItems);
      clearTimeout(timeout);
      GM_setValue(partNumber, "multiple_results");
      window.close();
      return true;
    }
  });
}

function main() {
  const pathname = window.location.pathname;
  if (pathname === "/") {
    setupShortcut();
  } else if (pathname.startsWith("/ps/")) {
    processSearchResults();
  }
}

main();
