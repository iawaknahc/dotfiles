import datetime
import math
from collections.abc import Generator
from dataclasses import dataclass
from typing import Literal, NamedTuple, Self, cast

from beancount.core import data
from whenever import Date, ItemizedDateDelta


class PluginError(NamedTuple):
    source: data.Meta
    message: str
    entry: data.Directive | None


TAG = "recurred"

META_recur_frequency = "recur_frequency"
META_recur_start = "recur_start"
META_recur_end = "recur_end"


def parse_iso8601_duration(
    *, name: str, meta: data.Meta, entry: data.Directive
) -> ItemizedDateDelta | PluginError:
    try:
        duration = ItemizedDateDelta(cast(str, meta[name]))
    except KeyError:
        return PluginError(
            source=meta,
            message=f"{name} must be present",
            entry=entry,
        )
    except TypeError, ValueError:
        return PluginError(
            source=meta,
            message=f"{name} must be a string of ISO 8601 duration, e.g. P1Y",
            entry=entry,
        )
    if duration.sign() != 1:
        return PluginError(
            source=meta,
            message=f"{name} must be a position ISO 8601 duration, e.g. P1Y",
            entry=entry,
        )
    return duration


def parse_iso8601_date(
    *, name: str, meta: data.Meta, entry: data.Directive
) -> Date | PluginError:
    try:
        date = Date(cast(str, meta[name]))
    except KeyError:
        return PluginError(
            source=meta,
            message=f"{name} must be present",
            entry=entry,
        )
    except TypeError, ValueError:
        return PluginError(
            source=meta,
            message=f"{name} must be a string of ISO 8601 date, e.g. 2026-06-11",
            entry=entry,
        )
    return date


def gen_idx_and_date(
    *,
    amortization_start: Date,
    amortization_frequency: ItemizedDateDelta,
    quotient: int,
    date_limit_exclusive: datetime.date,
) -> Generator[tuple[int, datetime.date]]:
    idx = 0
    limit = Date(date_limit_exclusive)
    whenever_date = amortization_start
    while idx < quotient and whenever_date <= limit:
        yield (idx, whenever_date.to_stdlib())
        idx += 1
        whenever_date = whenever_date.add(amortization_frequency)


def check_recur_frequency(
    *,
    recur_frequency: ItemizedDateDelta,
    source: data.Meta,
    entry: data.Directive,
) -> tuple[Literal["years", "months", "weeks", "days"], int] | PluginError:
    items = list(recur_frequency.items())
    if len(items) != 1:
        return PluginError(
            source=source,
            message="recur_frequency must be specified in a single unit, e.g. P1M",
            entry=entry,
        )
    return items[0]


def check_recur_quotient(
    *,
    recur_start: Date,
    recur_end: Date,
    item: tuple[Literal["years", "months", "weeks", "days"], int],
    source: data.Meta,
    entry: data.Directive,
) -> int | PluginError:
    values = list(
        recur_end.since(
            recur_start,
            in_units=[item[0]],
            round_mode="floor",
            round_increment=1,
        ).values()
    )
    assert len(values) == 1
    dividend = values[0]
    divisor = item[1]
    quotient = math.floor(dividend / divisor)
    if quotient <= 0:
        return PluginError(
            source=source,
            message="The recurrence range must be greater than or equal to recur_frequency",
            entry=entry,
        )
    return quotient


def recur_narration(
    *,
    quotient: int,
    recur_start: Date,
    recur_end: Date,
    original_narration: str | None,
    nth_period_0_based: int,
) -> str:
    if original_narration is not None:
        return f"{original_narration} ({recur_start.format_iso()} to {recur_end.format_iso()}) ({nth_period_0_based + 1}/{quotient})"
    return f"({recur_start.format_iso()} to {recur_end.format_iso()}) ({nth_period_0_based + 1}/{quotient})"


@dataclass
class RecurInstructionOnPosting:
    recur_frequency: ItemizedDateDelta
    recur_start: Date
    recur_end: Date
    quotient: int

    @classmethod
    def from_posting(
        cls, posting: data.Posting, transaction: data.Transaction
    ) -> Self | PluginError | None:
        assert posting.meta is not None
        if (
            META_recur_frequency not in posting.meta
            and META_recur_start not in posting.meta
            and META_recur_end not in posting.meta
        ):
            return None
        recur_start = parse_iso8601_date(
            name=META_recur_start, meta=posting.meta, entry=transaction
        )
        if isinstance(recur_start, PluginError):
            return recur_start
        recur_end = parse_iso8601_date(
            name=META_recur_end, meta=posting.meta, entry=transaction
        )
        if isinstance(recur_end, PluginError):
            return recur_end
        recur_frequency = parse_iso8601_duration(
            name=META_recur_frequency, meta=posting.meta, entry=transaction
        )
        if isinstance(recur_frequency, PluginError):
            return recur_frequency
        item = check_recur_frequency(
            recur_frequency=recur_frequency,
            source=posting.meta,
            entry=transaction,
        )
        if isinstance(item, PluginError):
            return item
        quotient = check_recur_quotient(
            recur_start=recur_start,
            recur_end=recur_end,
            item=item,
            source=posting.meta,
            entry=transaction,
        )
        if isinstance(quotient, PluginError):
            return quotient
        return cls(
            recur_frequency=recur_frequency,
            recur_start=recur_start,
            recur_end=recur_end,
            quotient=quotient,
        )


def recur_transaction(
    *,
    entry: data.Transaction,
    date_limit_exclusive: datetime.date,
) -> tuple[list[data.Directive], list[PluginError]]:
    errors: list[PluginError] = []
    instruction: RecurInstructionOnPosting | None = None

    for posting in entry.postings:
        if posting.meta is None:
            continue
        result = RecurInstructionOnPosting.from_posting(posting, entry)
        if isinstance(result, PluginError):
            errors.append(result)
        elif result is None:
            continue
        elif instruction is not None:
            errors.append(
                PluginError(
                    source=posting.meta,
                    message="Only one posting per transaction may have recur meta",
                    entry=entry,
                )
            )
        else:
            instruction = result

    if instruction is None:
        return [entry], errors

    generated: list[data.Directive] = []
    for idx, date in gen_idx_and_date(
        amortization_start=instruction.recur_start,
        amortization_frequency=instruction.recur_frequency,
        quotient=instruction.quotient,
        date_limit_exclusive=date_limit_exclusive,
    ):
        narration = recur_narration(
            quotient=instruction.quotient,
            recur_start=instruction.recur_start,
            recur_end=instruction.recur_end,
            original_narration=entry.narration,
            nth_period_0_based=idx,
        )
        generated.append(
            data.Transaction(
                meta=data.new_metadata("", 0, {"__automatic__": True}),
                date=date,
                flag=entry.flag,
                payee=entry.payee,
                narration=narration,
                tags=entry.tags | frozenset({TAG}),
                links=entry.links,
                postings=entry.postings,
            )
        )

    return generated, errors


def plugin(
    entries: list[data.Directive],
    _unused_options: dict[str, None] | None,
    _config_str: str | None = None,
) -> tuple[list[data.Directive], list[PluginError]]:
    today = datetime.date.today()
    errors: list[PluginError] = []
    out: list[data.Directive] = []

    for entry in entries:
        if isinstance(entry, data.Transaction) and TAG not in entry.tags:
            new_entries, new_errors = recur_transaction(
                entry=entry,
                date_limit_exclusive=today + datetime.timedelta(days=1),
            )
            errors.extend(new_errors)
            out.extend(new_entries)
        else:
            out.append(entry)

    return out, errors


__plugins__ = (plugin,)
