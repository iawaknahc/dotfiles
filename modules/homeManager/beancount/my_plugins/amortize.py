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


def multiply_ItemizedDateDelta(
    d: ItemizedDateDelta, multiplier: int
) -> ItemizedDateDelta:
    kwargs: dict[
        Literal["years"] | Literal["months"] | Literal["weeks"] | Literal["days"], int
    ] = {}
    for key, value in d.items():
        kwargs[key] = value * multiplier
    return ItemizedDateDelta(**kwargs)


@dataclass
class AmortizationInstruction:
    billing_period: ItemizedDateDelta
    billing_period_start: Date
    billing_period_end: Date
    amortization_period: ItemizedDateDelta
    number_of_amortization_periods: int

    @classmethod
    def is_target_account(cls, entry: data.Open) -> bool:
        if "billing_period" in entry.meta:
            return True
        return False

    @classmethod
    def is_target_posting(cls, posting: data.Posting) -> bool:
        if posting.meta is not None and "billing_period" in posting.meta:
            return True
        return False

    @classmethod
    def is_target_transaction(cls, entry: data.Transaction) -> bool:
        for posting in entry.postings:
            if posting.meta is not None and "billing_period" in posting.meta:
                return True
        return False

    @classmethod
    def from_posting(
        cls, posting: data.Posting, entry: data.Transaction
    ) -> Self | PluginError:
        assert posting.meta is not None
        try:
            billing_period = ItemizedDateDelta(
                cast(str, posting.meta["billing_period"])
            )
        except KeyError:
            return PluginError(
                source=posting.meta,
                message="billing_period must be present",
                entry=entry,
            )
        except TypeError, ValueError:
            return PluginError(
                source=posting.meta,
                message="billing_period must be a string of ISO 8601 duration, e.g. P1Y",
                entry=entry,
            )
        try:
            billing_period_start = Date(cast(str, posting.meta["billing_period_start"]))
        except KeyError:
            return PluginError(
                source=posting.meta,
                message="billing_period_start must be present",
                entry=entry,
            )
        except TypeError, ValueError:
            return PluginError(
                source=posting.meta,
                message="billing_period_start must be a string of ISO 8601 date, e.g. 2026-06-11",
                entry=entry,
            )
        try:
            billing_period_end = Date(cast(str, posting.meta["billing_period_end"]))
        except KeyError:
            return PluginError(
                source=posting.meta,
                message="billing_period_end must be present",
                entry=entry,
            )
        except TypeError, ValueError:
            return PluginError(
                source=posting.meta,
                message="billing_period_end must be a string of ISO 8601 date, e.g. 2026-06-11",
                entry=entry,
            )
        try:
            amortization_period = ItemizedDateDelta(
                cast(str, posting.meta["amortization_period"])
            )
        except KeyError:
            return PluginError(
                source=posting.meta,
                message="amortization_period must be present",
                entry=entry,
            )
        except TypeError, ValueError:
            return PluginError(
                source=posting.meta,
                message="amortization_period must be a string of ISO 8601 duration, e.g. P1Y",
                entry=entry,
            )

        # Validation
        if billing_period_start > billing_period_end:
            return PluginError(
                source=posting.meta,
                message="billing_period_start must be less than billing_period_end",
                entry=entry,
            )
        if billing_period.sign() != 1:
            return PluginError(
                source=posting.meta,
                message="billing_period must be a positive ISO 8601 duration, e.g. P1Y",
                entry=entry,
            )
        if amortization_period.sign() != 1:
            return PluginError(
                source=posting.meta,
                message="amortization_period must be a positive ISO 8601 duration, e.g. P1Y",
                entry=entry,
            )
        in_units = list(amortization_period.keys())
        if len(in_units) != 1:
            return PluginError(
                source=posting.meta,
                message="amortization_period must be specified in a single unit, e.g. P1M",
                entry=entry,
            )

        billing_period_in_terms_of_amortization_period = billing_period_end.since(
            billing_period_start, in_units=in_units
        )
        billing_period_in_terms_of_amortization_period_value = list(
            billing_period_in_terms_of_amortization_period.values()
        )[0]
        amortization_period_value = list(amortization_period.values())[0]
        if (
            billing_period_in_terms_of_amortization_period_value
            < amortization_period_value
        ):
            return PluginError(
                source=posting.meta,
                message="billing_period must be greater than or equal to amortization_period",
                entry=entry,
            )

        number_of_amortization_periods_float = (
            billing_period_in_terms_of_amortization_period_value
            / amortization_period_value
        )
        number_of_amortization_periods = math.floor(
            number_of_amortization_periods_float
        )
        if number_of_amortization_periods_float != number_of_amortization_periods:
            return PluginError(
                source=posting.meta,
                message="billing_period must be divisible by amortization_period, e.g. P1Y is divisible by P1M, the quotient is 12.",
                entry=entry,
            )

        if billing_period_start.add(billing_period) != billing_period_end:
            return PluginError(
                source=posting.meta,
                message="billing_period_start + billing_period must be equal to billing_period_end.",
                entry=entry,
            )

        return cls(
            billing_period=billing_period,
            billing_period_start=billing_period_start,
            billing_period_end=billing_period_end,
            amortization_period=amortization_period,
            number_of_amortization_periods=number_of_amortization_periods,
        )

    def equity_account_name(
        self, *, posting: data.Posting, transaction: data.Transaction
    ) -> str:
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
        return f"Equity:{txn_hash}"

    def equity_account_open_date(
        self,
        *,
        transaction_date: datetime.date,
    ) -> datetime.date:
        # Return the earlier of the two to ensure the account is opened for use.
        d1 = self.billing_period_start.to_stdlib()
        if d1 < transaction_date:
            return d1
        return transaction_date

    def equity_account_close_date(
        self, *, transaction_date: datetime.date
    ) -> datetime.date:
        # The account can be closed on the same date when the final period ends.
        # So the close date is the date of the final period.
        # The date of the final period is billing_period_start + (n - 1) * amortization_period

        assert self.number_of_amortization_periods >= 1
        period_to_add = multiply_ItemizedDateDelta(
            self.amortization_period, self.number_of_amortization_periods - 1
        )
        close_date_according_to_amortization_schedule = self.billing_period_start.add(
            period_to_add
        ).to_stdlib()

        # Return the later of the two to ensure the account is kept opened for use.
        if close_date_according_to_amortization_schedule > transaction_date:
            return close_date_according_to_amortization_schedule
        return transaction_date

    def amortization_amount(
        self,
        *,
        original: Decimal,
        currency: str,
    ) -> tuple[Decimal, Decimal | None]:
        num_periods = Decimal(self.number_of_amortization_periods)
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
        self, original_narration: str | None, nth_period_0_based: int
    ) -> str:
        num_periods = self.number_of_amortization_periods
        if original_narration is not None:
            return f"{original_narration} ({self.billing_period_start.format_iso()} to {self.billing_period_end.format_iso()}) ({nth_period_0_based + 1}/{num_periods})"
        return f"({self.billing_period_start.format_iso()} to {self.billing_period_end.format_iso()}) ({nth_period_0_based + 1}/{num_periods})"

    def gen_idx_and_date(
        self, date_limit_exclusive: datetime.date
    ) -> Generator[tuple[int, datetime.date]]:
        num_periods = self.number_of_amortization_periods
        idx = 0
        limit = Date(date_limit_exclusive)
        whenever_date = self.billing_period_start
        while idx < num_periods and whenever_date <= limit:
            yield (idx, whenever_date.to_stdlib())
            idx += 1
            whenever_date = whenever_date.add(self.amortization_period)

    def amortize_posting(
        self,
        *,
        transaction: data.Transaction,
        posting: data.Posting,
        date_limit_exclusive: datetime.date,
    ) -> tuple[data.Posting, list[data.Directive]]:
        entries: list[data.Directive] = []

        assert posting.units is not None

        open_date = self.equity_account_open_date(transaction_date=transaction.date)
        # If the open date of the equity account is beyond the limit,
        # it means we cannot amortize this posting now.
        if open_date > date_limit_exclusive:
            return posting, entries

        # Open the equity account.
        original_account = posting.account
        equity_account = self.equity_account_name(
            posting=posting, transaction=transaction
        )
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
        close_date = self.equity_account_close_date(transaction_date=transaction.date)
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
        amortization_amount, remainder = self.amortization_amount(
            original=posting.units.number, currency=posting.units.currency
        )
        num_periods = self.number_of_amortization_periods

        for idx, date in self.gen_idx_and_date(date_limit_exclusive):
            amount_number = amortization_amount
            if idx == num_periods - 1 and remainder is not None:
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
                    narration=self.amortization_narration(transaction.narration, idx),
                    tags=transaction.tags | frozenset({TAG}),
                    links=transaction.links,
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

        return posting, entries


def amortize(
    *, entry: data.Transaction, date_limit_exclusive: datetime.date
) -> tuple[list[data.Directive], list[PluginError]]:
    entries: list[data.Directive] = []
    errors: list[PluginError] = []

    amortized_at_least_once = False
    for idx, posting in enumerate(entry.postings):
        if posting.meta is not None and "billing_period" in posting.meta:
            instruction_or_error = AmortizationInstruction.from_posting(posting, entry)
            if isinstance(instruction_or_error, PluginError):
                errors.append(instruction_or_error)
            else:
                new_posting, new_entries = instruction_or_error.amortize_posting(
                    transaction=entry,
                    posting=posting,
                    date_limit_exclusive=date_limit_exclusive,
                )
                amortized_at_least_once = True
                # Modify the list in-place.
                entry.postings[idx] = new_posting
                for e in new_entries:
                    entries.append(e)
    if amortized_at_least_once:
        entry = entry._replace(tags=entry.tags | frozenset({TAG}))

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

    # This plugin does two things.
    # 1. It amortizes an expense in a transaction if the posting contains a meta key "billing_period".
    # 2. If an account has a meta key "billing_period", and it appears in a postings without the meta key, then it is an error.
    #    The rationale is ensure that once an account is supposed to be amortized, it is always amortized.

    opted_in_accounts: set[str] = set()
    for entry in entries:
        if isinstance(entry, data.Open) and AmortizationInstruction.is_target_account(
            entry
        ):
            opted_in_accounts.add(entry.account)

    out: list[data.Directive] = []
    for entry in entries:
        if isinstance(entry, data.Transaction):
            for posting in entry.postings:
                if (
                    posting.account in opted_in_accounts
                    and not AmortizationInstruction.is_target_posting(posting)
                ):
                    errors.append(
                        PluginError(
                            source=posting.meta or entry.meta,
                            message=f"{posting.account} has opted in amortization but this posting has no amortization instructions.",
                            entry=entry,
                        ),
                    )

        if (
            not isinstance(entry, data.Transaction)
            or TAG in entry.tags
            or not AmortizationInstruction.is_target_transaction(entry)
        ):
            out.append(entry)
        else:
            new_entries, new_errors = amortize(
                entry=entry, date_limit_exclusive=today + datetime.timedelta(days=1)
            )
            for e in new_errors:
                errors.append(e)
            for e in new_entries:
                out.append(e)

    return out, errors


__plugins__ = (plugin,)
