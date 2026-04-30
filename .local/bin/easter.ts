#!/usr/bin/env deno

let year: number;
if (Deno.args[0] != null) {
  const yearStr = Deno.args[0];
  const y = parseInt(yearStr, 10);
  if (isNaN(y)) {
    console.error(`expected year to be an integer: ${yearStr}`);
    Deno.exit(1);
  }

  if (y < 1583) {
    console.error(
      `expected year >= 1583, the first Easter when Gregorian calendar was put in use: ${y}`,
    );
    Deno.exit(1);
  }

  year = y;
} else {
  year = Temporal.Now.plainDateISO().year;
}

// A translation of the algorithm documented at https://en.wikipedia.org/wiki/Date_of_Easter#Anonymous_Gregorian_algorithm
const a = year % 19;
const b = Math.floor(year / 100);
const c = year % 100;
const d = Math.floor(b / 4);
const e = b % 4;
const f = Math.floor((b + 8) / 25);
const g = Math.floor((b - f + 1) / 3);
const h = (19 * a + b - d - g + 15) % 30;
const i = Math.floor(c / 4);
const k = c % 4;
const l = (32 + 2 * e + 2 * i - h - k) % 7;
const m = Math.floor((a + 11 * h + 22 * l) / 451);
const n = Math.floor((h + l - 7 * m + 114) / 31);
const o = (h + l - 7 * m + 114) % 31;

const month = n;
const dayOfMonth = o + 1;

const plainDate = new Temporal.PlainDate(year, month, dayOfMonth);
console.log(plainDate.toString());
