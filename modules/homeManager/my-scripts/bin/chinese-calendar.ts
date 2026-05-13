#!/usr/bin/env -S deno run --allow-run=solar-term.py

interface SolarTerm {
  name: string;
  degree: number;
}

interface MonthDay {
  monthCodeAndDay: string;
  aliases: string[];
}

const SOLAR_TERMS: SolarTerm[] = [
  { name: "小寒", degree: 285 },
  { name: "大寒", degree: 300 },
  { name: "立春", degree: 315 },
  { name: "雨水", degree: 330 },
  { name: "驚蟄", degree: 345 },
  { name: "春分", degree: 0 },
  { name: "清明", degree: 15 },
  { name: "穀雨", degree: 30 },
  { name: "立夏", degree: 45 },
  { name: "小滿", degree: 60 },
  { name: "芒種", degree: 75 },
  { name: "夏至", degree: 90 },
  { name: "小暑", degree: 105 },
  { name: "大暑", degree: 120 },
  { name: "立秋", degree: 135 },
  { name: "處暑", degree: 150 },
  { name: "白露", degree: 165 },
  { name: "秋分", degree: 180 },
  { name: "寒露", degree: 195 },
  { name: "霜降", degree: 210 },
  { name: "立冬", degree: 225 },
  { name: "小雪", degree: 240 },
  { name: "大雪", degree: 255 },
  { name: "冬至", degree: 270 },
];

const KNOWN_MONTH_DAYS: MonthDay[] = [
  {
    monthCodeAndDay: "M01-01",
    aliases: ["正月初一", "年初一"],
  },
  {
    monthCodeAndDay: "M01-02",
    aliases: ["正月初二", "年初二", "車公誕"],
  },
  {
    monthCodeAndDay: "M01-03",
    aliases: ["正月初三", "年初三"],
  },
  {
    monthCodeAndDay: "M01-04",
    aliases: ["正月初四", "年初四"],
  },
  {
    monthCodeAndDay: "M01-05",
    aliases: ["正月初五", "年初五"],
  },
  {
    monthCodeAndDay: "M01-06",
    aliases: ["正月初六", "年初六"],
  },
  {
    monthCodeAndDay: "M01-07",
    aliases: ["正月初七", "年初七"],
  },
  {
    monthCodeAndDay: "M01-08",
    aliases: ["正月初八", "年初八"],
  },
  {
    monthCodeAndDay: "M01-09",
    aliases: ["正月初九", "年初九"],
  },
  {
    monthCodeAndDay: "M01-10",
    aliases: ["正月初十", "年初十"],
  },
  {
    monthCodeAndDay: "M01-15",
    aliases: ["正月十五", "元宵節"],
  },
  {
    monthCodeAndDay: "M03-23",
    aliases: ["天后誕"],
  },
  {
    monthCodeAndDay: "M04-08",
    aliases: ["佛誕", "長洲太平清醮", "譚公誕"],
  },
  {
    monthCodeAndDay: "M05-05",
    aliases: ["端午節"],
  },
  {
    monthCodeAndDay: "M06-24",
    aliases: ["關帝誕"],
  },
  {
    monthCodeAndDay: "M07-07",
    aliases: ["七夕"],
  },
  {
    monthCodeAndDay: "M07-14",
    aliases: ["七月十四"],
  },
  {
    monthCodeAndDay: "M07-15",
    aliases: ["盂蘭節"],
  },
  {
    monthCodeAndDay: "M08-15",
    aliases: ["中秋節"],
  },
  {
    monthCodeAndDay: "M09-09",
    aliases: ["重陽節"],
  },
];

function format_available_queries() {
  let out = "";
  for (const monthDay of KNOWN_MONTH_DAYS) {
    out += `${monthDay.monthCodeAndDay} ${monthDay.aliases.join(" ")}\n`;
  }
  for (const solarTerm of SOLAR_TERMS) {
    out += `${solarTerm.name}\n`;
  }

  return out;
}

function parseQuery(query: string): SolarTerm | MonthDay | null {
  for (const monthDay of KNOWN_MONTH_DAYS) {
    if (query === monthDay.monthCodeAndDay) {
      return monthDay;
    }
    for (const alias of monthDay.aliases) {
      if (query === alias) {
        return monthDay;
      }
    }
  }

  for (const solarTerm of SOLAR_TERMS) {
    if (query === solarTerm.name) {
      return solarTerm;
    }
  }

  return null;
}

function isMonthDay(a: SolarTerm | MonthDay): a is MonthDay {
  return Object.prototype.hasOwnProperty.call(a, "monthCodeAndDay");
}

async function main() {
  const query = Deno.args[0];
  if (query == null) {
    console.error(
      `expected query to be one of:\n${format_available_queries()}`,
    );
    Deno.exit(1);
  }

  const parsedQuery = parseQuery(query);
  if (parsedQuery == null) {
    console.error(
      `expected query to be one of:\n${format_available_queries()}`,
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

  if (isMonthDay(parsedQuery)) {
    // The input year, in Chinese calendar.
    const chineseYear = Temporal.Now.plainDateISO()
      .with({ year: isoYear })
      .withCalendar("chinese").year;

    const parts = parsedQuery.monthCodeAndDay.split("-");
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
  } else {
    const degree = parsedQuery.degree;
    const command = new Deno.Command("solar-term.py", {
      args: [`${degree}`, `${isoYear}`],
      stdin: "null",
      stdout: "inherit",
      stderr: "inherit",
    });
    const process = command.spawn();
    const status = await process.status;
    Deno.exit(status.code);
  }
}

await main();
