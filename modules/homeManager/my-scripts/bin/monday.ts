#!/usr/bin/env deno

// hledger does not support notation like "2026-W20".
// This script allows us to write `hledger is --period "weekly $(monday.ts 2026-W20)"`.

const PATTERN = /^(\d{4})-W(0[1-9]|[1-4][0-9]|5[0-3])$/;

function mondayInWeek(
  yearOfWeek: number,
  weekNumber: number,
): Temporal.PlainDate {
  const jan4 = Temporal.PlainDate.from({
    year: yearOfWeek,
    month: 1,
    day: 4,
  });
  const mondayInWeek1 = jan4.subtract({ days: jan4.dayOfWeek - 1 });
  const mondayInWeekN = mondayInWeek1.add({ weeks: weekNumber - 1 });
  return mondayInWeekN;
}

if (Deno.args[0] != null) {
  const match = PATTERN.exec(Deno.args[0]);
  if (match == null) {
    console.error("expected argument to be a ISO week, e.g. 2026-W01");
    Deno.exit(1);
  }

  const yearOfWeek = parseInt(match[1], 10);
  const weekNumber = parseInt(match[2], 10);
  const mondayInWeekN = mondayInWeek(yearOfWeek, weekNumber);
  console.log(mondayInWeekN.toString());
} else {
  const today = Temporal.Now.plainDateISO();
  const yearOfWeek = today.yearOfWeek;
  const weekNumber = today.weekOfYear;
  if (yearOfWeek == null || weekNumber == null) {
    console.error("expected the default calendar to be ISO");
    Deno.exit(1);
  }
  const mondayInWeekN = mondayInWeek(yearOfWeek, weekNumber);
  console.log(mondayInWeekN.toString());
}
