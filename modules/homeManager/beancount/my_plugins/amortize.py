import datetime
import math
from collections.abc import Generator
from dataclasses import dataclass
from decimal import Decimal
from typing import Literal, NamedTuple, Self, cast

from beancount.core import compare, data
from beancount.core.amount import Amount
from whenever import Date, ItemizedDateDelta

from my_plugins.currencies import (  # pyright: ignore[reportMissingTypeStubs]
    get_decimal_for_quantization,
)


class PluginError(NamedTuple):
    source: data.Meta
    message: str
    entry: data.Directive | None


TAG = "amortized"

ACCOUNT_EXPENSES = "Expenses:"

META_amortization_frequency = "amortization_frequency"
META_amortization_start = "amortization_start"
META_amortization_end = "amortization_end"

META_billing_period = "billing_period"
META_billing_period_start = "billing_period_start"
META_billing_amortization_enabled = "billing_amortization_enabled"


@dataclass
class AmortizationResult:
    posting: data.Posting
    links: frozenset[str]
    entries: list[data.Directive]


def multiply_ItemizedDateDelta(
    d: ItemizedDateDelta, multiplier: int
) -> ItemizedDateDelta:
    kwargs: dict[
        Literal["years"] | Literal["months"] | Literal["weeks"] | Literal["days"], int
    ] = {}
    for key, value in d.items():
        kwargs[key] = value * multiplier
    return ItemizedDateDelta(**kwargs)


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


def check_amortization_period(
    *,
    amortization_frequency: ItemizedDateDelta,
    source: data.Meta,
    entry: data.Directive,
) -> tuple[Literal["years", "months", "weeks", "days"], int] | PluginError:
    items = list(amortization_frequency.items())
    if len(items) != 1:
        return PluginError(
            source=source,
            message="amortization_period must be specified in a single unit, e.g. P1M",
            entry=entry,
        )
    return items[0]


def check_quotient(
    *,
    amortization_start: Date,
    amortization_end: Date,
    item: tuple[Literal["years", "months", "weeks", "days"], int],
    source: data.Meta,
    entry: data.Directive,
) -> int | PluginError:
    values = list(
        amortization_end.since(
            amortization_start,
            in_units=[item[0]],
            round_mode="floor",
            round_increment=1,
        ).values()
    )
    # It should be 1 because len(in_units) == 1
    assert len(values) == 1

    dividend = values[0]
    divisor = item[1]
    quotient = math.floor(dividend / divisor)
    if quotient <= 0:
        return PluginError(
            source=source,
            message="The whole amortization period must be greater than or equal to amortization_frequency",
            entry=entry,
        )
    return quotient


def equity_account_name_and_link(
    *, posting: data.Posting, transaction: data.Transaction
) -> tuple[str, str]:
    # We want to generate a unique but somehow deterministic account name.
    # We want to support amortize on more than one postings in the same transaction.
    # So we do a trick here.
    # We are going to construct a transaction with only the posting being amortized.
    # This is not a valid transaction because it is probably not balanced.
    # But it gives the hash we want.
    cloned = data.Transaction(
        meta=transaction.meta,
        date=transaction.date,
        flag=transaction.flag,
        payee=transaction.payee,
        narration=transaction.narration,
        tags=transaction.tags,
        links=transaction.links,
        postings=[posting],
    )
    txn_hash = compare.hash_entry(cloned, exclude_meta=False).upper()
    return f"Equity:{txn_hash}", f"amortization-{txn_hash}"


def equity_account_open_date(
    *,
    transaction_date: datetime.date,
    amortization_start: Date,
) -> datetime.date:
    # Return the earlier of the two to ensure the account is opened for use.
    d1 = amortization_start.to_stdlib()
    if d1 < transaction_date:
        return d1
    return transaction_date


def equity_account_close_date(
    *,
    transaction_date: datetime.date,
    amortization_start: Date,
    amortization_frequency: ItemizedDateDelta,
    quotient: int,
) -> datetime.date:
    # The account can be closed on the same date when the final period ends.
    # So the close date is the date of the final period.
    # The date of the final period is amortization + (n - 1) * amortization_period

    assert quotient >= 1
    period_to_add = multiply_ItemizedDateDelta(amortization_frequency, quotient - 1)
    close_date_according_to_amortization_schedule = amortization_start.add(
        period_to_add
    ).to_stdlib()

    # Return the later of the two to ensure the account is kept opened for use.
    if close_date_according_to_amortization_schedule > transaction_date:
        return close_date_according_to_amortization_schedule
    return transaction_date


def get_amortization_amount(
    *,
    quotient: int,
    original: Decimal,
    currency: str,
) -> tuple[Decimal, Decimal | None]:
    num_periods = Decimal(quotient)
    amortization_mount_per_period = original / num_periods

    decimal_for_quantization = get_decimal_for_quantization(currency)
    # Not a currency, then we just assume the number of decimal places is unbounded.
    if decimal_for_quantization is None:
        return (amortization_mount_per_period, None)

    amortization_mount_per_period = amortization_mount_per_period.quantize(
        decimal_for_quantization
    )
    product = amortization_mount_per_period * num_periods
    adjustment = original - product
    if adjustment == Decimal(0):
        return (amortization_mount_per_period, None)
    return (amortization_mount_per_period, adjustment)


def amortization_narration(
    *,
    quotient: int,
    amortization_start: Date,
    amortization_end: Date,
    original_narration: str | None,
    nth_period_0_based: int,
) -> str:
    if original_narration is not None:
        return f"{original_narration} ({amortization_start.format_iso()} to {amortization_end.format_iso()}) ({nth_period_0_based + 1}/{quotient})"
    return f"({amortization_start.format_iso()} to {amortization_end.format_iso()}) ({nth_period_0_based + 1}/{quotient})"


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


def amortize_posting(
    *,
    amortization_start: Date,
    amortization_end: Date,
    amortization_frequency: ItemizedDateDelta,
    quotient: int,
    transaction: data.Transaction,
    posting: data.Posting,
    date_limit_exclusive: datetime.date,
) -> AmortizationResult:
    entries: list[data.Directive] = []

    assert posting.units is not None

    open_date = equity_account_open_date(
        transaction_date=transaction.date, amortization_start=amortization_start
    )
    # If the open date of the equity account is beyond the limit,
    # it means we cannot amortize this posting now.
    if open_date > date_limit_exclusive:
        return AmortizationResult(
            posting=posting,
            links=frozenset(),
            entries=entries,
        )

    # Open the equity account.
    original_account = posting.account
    equity_account, link = equity_account_name_and_link(
        posting=posting, transaction=transaction
    )
    tags = frozenset({TAG})
    links = frozenset({link})
    entries.append(
        data.Open(
            meta=data.new_metadata(
                "",
                0,
                {
                    "__automatic__": True,
                },
            ),
            date=open_date,
            account=equity_account,
            currencies=[posting.units.currency],
            booking=None,
        )
    )

    # Close the account, if allowed to do so.
    close_date = equity_account_close_date(
        transaction_date=transaction.date,
        amortization_start=amortization_start,
        amortization_frequency=amortization_frequency,
        quotient=quotient,
    )
    if close_date <= date_limit_exclusive:
        entries.append(
            data.Close(
                meta=data.new_metadata(
                    "",
                    0,
                    {
                        "__automatic__": True,
                    },
                ),
                date=close_date,
                account=equity_account,
            )
        )
        # Assert the balance 1 day after the close date
        entries.append(
            data.Balance(
                meta=data.new_metadata(
                    "",
                    0,
                    {
                        "__automatic__": True,
                    },
                ),
                date=close_date + datetime.timedelta(days=1),
                account=equity_account,
                amount=Amount(number=Decimal(0), currency=posting.units.currency),
                tolerance=None,
                diff_amount=None,
            ),
        )

    # Modify the posting
    posting = posting._replace(account=equity_account)
    assert posting.units is not None
    assert posting.units.number is not None

    # Insert amortized transactions.
    amortization_amount, remainder = get_amortization_amount(
        quotient=quotient,
        original=posting.units.number,
        currency=posting.units.currency,
    )

    for idx, date in gen_idx_and_date(
        amortization_frequency=amortization_frequency,
        amortization_start=amortization_start,
        quotient=quotient,
        date_limit_exclusive=date_limit_exclusive,
    ):
        amount_number = amortization_amount
        if idx == quotient - 1 and remainder is not None:
            amount_number += remainder

        entries.append(
            data.Transaction(
                meta=data.new_metadata(
                    "",
                    0,
                    {
                        "__automatic__": True,
                    },
                ),
                date=date,
                # Intentionally NOT to inherit the flag.
                # It is because the original transaction may be flagged as `!`.
                # If the generated transaction inherits it, there will be many warnings.
                flag="*",
                payee=transaction.payee,
                narration=amortization_narration(
                    amortization_start=amortization_start,
                    amortization_end=amortization_end,
                    quotient=quotient,
                    original_narration=transaction.narration,
                    nth_period_0_based=idx,
                ),
                tags=transaction.tags | tags,
                links=transaction.links | links,
                postings=[
                    data.Posting(
                        meta=data.new_metadata(
                            "",
                            0,
                            {
                                "__automatic__": True,
                            },
                        ),
                        account=original_account,
                        units=Amount(
                            number=amount_number,
                            currency=posting.units.currency,
                        ),
                        cost=None,
                        price=None,
                        flag=None,
                    ),
                    data.Posting(
                        meta=data.new_metadata(
                            "",
                            0,
                            {
                                "__automatic__": True,
                            },
                        ),
                        account=equity_account,
                        units=Amount(
                            number=-amount_number,
                            currency=posting.units.currency,
                        ),
                        cost=None,
                        price=None,
                        flag=None,
                    ),
                ],
            ),
        )

    return AmortizationResult(
        posting=posting,
        entries=entries,
        links=links,
    )


@dataclass
class BillingInstructionOnOpenDirective:
    subscription_start: Date
    billing_period: ItemizedDateDelta
    amortization_frequency: ItemizedDateDelta
    quotient: int

    @classmethod
    def is_target_account(cls, entry: data.Open) -> bool:
        if (
            META_billing_period in entry.meta
            or META_amortization_frequency in entry.meta
        ):
            return True
        return False

    @classmethod
    def from_open(cls, entry: data.Open) -> Self | PluginError:
        if not entry.account.startswith(ACCOUNT_EXPENSES):
            return PluginError(
                source=entry.meta,
                message="Amortization is applicable to expenses only",
                entry=entry,
            )
        subscription_start = Date(entry.date)
        billing_period = parse_iso8601_duration(
            name=META_billing_period, meta=entry.meta, entry=entry
        )
        if isinstance(billing_period, PluginError):
            return billing_period
        amortization_frequency = parse_iso8601_duration(
            name=META_amortization_frequency, meta=entry.meta, entry=entry
        )
        if isinstance(amortization_frequency, PluginError):
            return amortization_frequency
        item = check_amortization_period(
            amortization_frequency=amortization_frequency,
            source=entry.meta,
            entry=entry,
        )
        if isinstance(item, PluginError):
            return item
        quotient = check_quotient(
            amortization_start=subscription_start,
            amortization_end=subscription_start.add(billing_period),
            item=item,
            source=entry.meta,
            entry=entry,
        )
        if isinstance(quotient, PluginError):
            return quotient
        return cls(
            subscription_start=subscription_start,
            billing_period=billing_period,
            amortization_frequency=amortization_frequency,
            quotient=quotient,
        )


@dataclass
class BillingInstructionOnPosting:
    billing_period_start: Date
    instruction_on_open: BillingInstructionOnOpenDirective

    @classmethod
    def from_posting(
        cls,
        instruction_on_open: BillingInstructionOnOpenDirective,
        posting: data.Posting,
        transaction: data.Transaction,
    ) -> Self | PluginError:
        assert posting.meta is not None
        billing_period_start = parse_iso8601_date(
            name=META_billing_period_start, meta=posting.meta, entry=transaction
        )
        if isinstance(billing_period_start, PluginError):
            return billing_period_start
        return cls(
            instruction_on_open=instruction_on_open,
            billing_period_start=billing_period_start,
        )


@dataclass
class OneOffAmortizationInstructionOnPosting:
    amortization_frequency: ItemizedDateDelta
    amortization_start: Date
    amortization_end: Date
    quotient: int

    @classmethod
    def from_posting(
        cls, posting: data.Posting, transaction: data.Transaction
    ) -> Self | PluginError | None:
        assert posting.meta is not None
        if (
            META_amortization_frequency not in posting.meta
            and META_amortization_start not in posting.meta
            and META_amortization_end not in posting.meta
        ):
            return None
        if not posting.account.startswith(ACCOUNT_EXPENSES):
            return PluginError(
                source=posting.meta,
                message="Amortization is applicable to expenses only",
                entry=transaction,
            )
        amortization_start = parse_iso8601_date(
            name=META_amortization_start, meta=posting.meta, entry=transaction
        )
        if isinstance(amortization_start, PluginError):
            return amortization_start
        amortization_end = parse_iso8601_date(
            name=META_amortization_end, meta=posting.meta, entry=transaction
        )
        if isinstance(amortization_end, PluginError):
            return amortization_end
        amortization_frequency = parse_iso8601_duration(
            name=META_amortization_frequency, meta=posting.meta, entry=transaction
        )
        if isinstance(amortization_frequency, PluginError):
            return amortization_frequency
        item = check_amortization_period(
            amortization_frequency=amortization_frequency,
            source=posting.meta,
            entry=transaction,
        )
        if isinstance(item, PluginError):
            return item
        quotient = check_quotient(
            amortization_start=amortization_start,
            amortization_end=amortization_end,
            item=item,
            source=posting.meta,
            entry=transaction,
        )
        if isinstance(quotient, PluginError):
            return quotient
        return cls(
            amortization_start=amortization_start,
            amortization_end=amortization_end,
            amortization_frequency=amortization_frequency,
            quotient=quotient,
        )


def amortize_transaction(
    *,
    entry: data.Transaction,
    date_limit_exclusive: datetime.date,
    opted_in_accounts: dict[str, BillingInstructionOnOpenDirective],
) -> tuple[list[data.Directive], list[PluginError]]:
    entries: list[data.Directive] = []
    errors: list[PluginError] = []

    links: frozenset[str] = frozenset()
    for idx, posting in enumerate(entry.postings):
        if posting.meta is None:
            continue

        one_off: OneOffAmortizationInstructionOnPosting | PluginError | None = (
            OneOffAmortizationInstructionOnPosting.from_posting(posting, entry)
        )
        billing: BillingInstructionOnPosting | PluginError | None = None
        if posting.account in opted_in_accounts and (
            META_billing_amortization_enabled not in posting.meta
            or posting.meta[META_billing_amortization_enabled] is not False
        ):
            billing = BillingInstructionOnPosting.from_posting(
                opted_in_accounts[posting.account], posting, entry
            )

        if isinstance(one_off, PluginError):
            errors.append(one_off)
            continue

        if isinstance(billing, PluginError):
            errors.append(billing)
            continue

        match (one_off, billing):
            case (None, None):
                pass
            case (None, billing):
                assert billing is not None
                result = amortize_posting(
                    amortization_frequency=billing.instruction_on_open.amortization_frequency,
                    amortization_start=billing.billing_period_start,
                    amortization_end=billing.billing_period_start.add(
                        billing.instruction_on_open.billing_period
                    ),
                    quotient=billing.instruction_on_open.quotient,
                    transaction=entry,
                    posting=posting,
                    date_limit_exclusive=date_limit_exclusive,
                )
                links = links | result.links
                # Modify the list in-place.
                entry.postings[idx] = result.posting
                for e in result.entries:
                    entries.append(e)
            case (one_off, None):
                assert one_off is not None
                result = amortize_posting(
                    amortization_frequency=one_off.amortization_frequency,
                    amortization_start=one_off.amortization_start,
                    amortization_end=one_off.amortization_end,
                    quotient=one_off.quotient,
                    transaction=entry,
                    posting=posting,
                    date_limit_exclusive=date_limit_exclusive,
                )
                links = links | result.links
                # Modify the list in-place.
                entry.postings[idx] = result.posting
                for e in result.entries:
                    entries.append(e)
            case (_, _):
                errors.append(
                    PluginError(
                        source=posting.meta,
                        message="The posting has billing amortization and one-off amortization. They conflict with each other.",
                        entry=entry,
                    )
                )

    if len(links) > 0:
        entry = entry._replace(
            tags=entry.tags | frozenset({TAG}), links=entry.links | links
        )

    # If there is any errors, return the transaction unmodified.
    if len(errors) > 0:
        return [entry], errors
    # Otherwise, return modified transactions.
    return [entry] + entries, errors


def plugin(
    entries: list[data.Directive],
    _unused_options: dict[str, None] | None,
    _config_str: str | None = None,
) -> tuple[list[data.Directive], list[PluginError]]:
    today = datetime.date.today()
    errors: list[PluginError] = []

    opted_in_accounts: dict[str, BillingInstructionOnOpenDirective] = {}
    for entry in entries:
        if isinstance(
            entry, data.Open
        ) and BillingInstructionOnOpenDirective.is_target_account(entry):
            instruction = BillingInstructionOnOpenDirective.from_open(entry)
            if isinstance(instruction, PluginError):
                errors.append(instruction)
            else:
                opted_in_accounts[entry.account] = instruction

    out: list[data.Directive] = []
    for entry in entries:
        if isinstance(entry, data.Transaction) and TAG not in entry.tags:
            new_entries, new_errors = amortize_transaction(
                entry=entry,
                date_limit_exclusive=today + datetime.timedelta(days=1),
                opted_in_accounts=opted_in_accounts,
            )
            for e in new_errors:
                errors.append(e)
            for e in new_entries:
                out.append(e)
        else:
            out.append(entry)

    return out, errors


__plugins__ = (plugin,)
