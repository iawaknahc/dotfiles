#!/usr/bin/env deno

const monthDayStrings = [
  "M01-01", // 正月初一
  "M01-02", // 正月初二
  "M01-03", // 正月初三
  "M01-04", // 正月初四
  "M01-05", // 正月初五
  "M01-06", // 正月初六
  "M01-07", // 正月初七
  "M01-08", // 正月初八
  "M01-09", // 正月初九
  "M01-10", // 正月初十
  "M01-15", // 元宵節
  "M04-08", // 香港的佛誕
  "M05-05", // 端午節
  "M07-07", // 七夕
  "M07-14", // 七月十四
  "M07-15", // 盂蘭節
  "M08-15", // 中秋節
  "M09-09", // 重陽節
];

const monthDayString = Deno.args[0];
if (monthDayString == null) {
  console.error(
    `expected festival to be one of: ${JSON.stringify(monthDayStrings)}`,
  );
  Deno.exit(1);
}
const monthDayStringIndex = monthDayStrings.indexOf(monthDayString);
if (monthDayStringIndex < 0) {
  console.error(
    `expected festival to be one of: ${JSON.stringify(monthDayStrings)}`,
  );
  Deno.exit(1);
}

// The input year, in ISO 8601 calendar.
let isoYear: number;
if (Deno.args[1] != null) {
  const yearStr = Deno.args[1];
  const y = parseInt(yearStr, 10);
  if (isNaN(y)) {
    console.error(`expected year to be an integer: ${yearStr}`);
    Deno.exit(1);
  }

  if (y < 1583) {
    console.error(
      `expected year >= 1583, the first whole year when Gregorian calendar was put in use: ${y}`,
    );
    Deno.exit(1);
  }

  isoYear = y;
} else {
  isoYear = Temporal.Now.plainDateISO().year;
}

// The input year, in Chinese calendar.
const chineseYear = Temporal.Now.plainDateISO()
  .with({ year: isoYear })
  .withCalendar("chinese").year;

const parts = monthDayString.split("-");
const monthCode = parts[0];
const day = parseInt(parts[1], 10);

const monthDay = Temporal.PlainMonthDay.from({
  monthCode,
  day,
  calendar: "chinese",
});

const answer = monthDay
  .toPlainDate({ year: chineseYear })
  .withCalendar("iso8601");

console.log(answer.toString());
