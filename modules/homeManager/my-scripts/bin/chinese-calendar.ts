#!/usr/bin/env deno

const KNOWN_DAYS = [
  {
    key: "M01-01",
    aliases: ["正月初一", "年初一"],
  },
  {
    key: "M01-02",
    aliases: ["正月初二", "年初二", "車公誕"],
  },
  {
    key: "M01-03",
    aliases: ["正月初三", "年初三"],
  },
  {
    key: "M01-04",
    aliases: ["正月初四", "年初四"],
  },
  {
    key: "M01-05",
    aliases: ["正月初五", "年初五"],
  },
  {
    key: "M01-06",
    aliases: ["正月初六", "年初六"],
  },
  {
    key: "M01-07",
    aliases: ["正月初七", "年初七"],
  },
  {
    key: "M01-08",
    aliases: ["正月初八", "年初八"],
  },
  {
    key: "M01-09",
    aliases: ["正月初九", "年初九"],
  },
  {
    key: "M01-10",
    aliases: ["正月初十", "年初十"],
  },
  {
    key: "M01-15",
    aliases: ["正月十五", "元宵節"],
  },
  {
    key: "M03-23",
    aliases: ["天后誕"],
  },
  {
    key: "M04-08",
    aliases: ["佛誕", "長洲太平清醮", "譚公誕"],
  },
  {
    key: "M05-05",
    aliases: ["端午節"],
  },
  {
    key: "M06-24",
    aliases: ["關帝誕"],
  },
  {
    key: "M07-07",
    aliases: ["七夕"],
  },
  {
    key: "M07-14",
    aliases: ["七月十四"],
  },
  {
    key: "M07-15",
    aliases: ["盂蘭節"],
  },
  {
    key: "M08-15",
    aliases: ["中秋節"],
  },
  {
    key: "M09-09",
    aliases: ["重陽節"],
  },
];

function format_KNOWN_DAYS() {
  let out = "";
  for (const day of KNOWN_DAYS) {
    out += `${day.key} ${day.aliases.join(" ")}\n`;
  }
  return out;
}

function getMonthDayString(keyOrAlias: string): string | null {
  for (const day of KNOWN_DAYS) {
    if (keyOrAlias === day.key) {
      return day.key;
    }
    for (const alias of day.aliases) {
      if (keyOrAlias === alias) {
        return day.key;
      }
    }
  }
  return null;
}

function main() {
  const keyOrAlias = Deno.args[0];
  if (keyOrAlias == null) {
    console.error(`expected festival to be one of:\n${format_KNOWN_DAYS()}`);
    Deno.exit(1);
  }

  const monthDayString = getMonthDayString(keyOrAlias);
  if (monthDayString == null) {
    console.error(`expected festival to be one of:\n${format_KNOWN_DAYS()}`);
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
}

main();
