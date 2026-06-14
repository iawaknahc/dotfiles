from dataclasses import dataclass
from decimal import Decimal
from typing import NamedTuple, cast

from beancount.core import data
from beancount.core.amount import Amount
from beancount.core.position import Cost

TAG = "cost-basis-adjustment"

META_base_currency = "base_currency"
META_quote_currency = "quote_currency"


class PluginError(NamedTuple):
    source: data.Meta
    message: str
    entry: data.Directive | None


@dataclass
class FixedAsset:
    account: str
    base_currency: str
    quote_currency: str
    cost_basis: list[Cost]


def validate_currency(entry: data.Open, key: str) -> str | PluginError:
    try:
        base_currency = entry.meta[key]  # pyright: ignore[reportAny]
        if not isinstance(base_currency, str):
            raise TypeError()
        if base_currency not in entry.currencies:
            raise ValueError()
        return base_currency
    except KeyError:
        return PluginError(
            source=entry.meta,
            message=f"{key} must be present",
            entry=entry,
        )
    except TypeError:
        return PluginError(
            source=entry.meta,
            message=f"{key} must be a string",
            entry=entry,
        )
    except ValueError:
        return PluginError(
            source=entry.meta,
            message=f"{key} is not an allowed currency of this account",
            entry=entry,
        )


def validate_open(entry: data.Open) -> FixedAsset | list[PluginError]:
    errors: list[PluginError] = []
    if len(entry.currencies) != 2:
        errors.append(
            PluginError(
                source=entry.meta,
                message="Fixed asset account must have only 2 currencies, the base currency and the quote currency.",
                entry=entry,
            )
        )

    base_currency = validate_currency(entry, META_base_currency)
    quote_currency = validate_currency(entry, META_quote_currency)
    if isinstance(base_currency, str) and isinstance(quote_currency, str):
        return FixedAsset(
            account=entry.account,
            base_currency=base_currency,
            quote_currency=quote_currency,
            cost_basis=[],
        )

    if isinstance(base_currency, PluginError):
        errors.append(base_currency)
    if isinstance(quote_currency, PluginError):
        errors.append(quote_currency)
    return errors


def plugin(
    entries: list[data.Directive],
    _unused_options: dict[str, None] | None,
    _config_str: str | None = None,
) -> tuple[list[data.Directive], list[PluginError]]:
    errors: list[PluginError] = []

    accounts: dict[str, FixedAsset] = {}

    for entry in entries:
        if isinstance(entry, data.Open):
            if META_base_currency in entry.meta or META_quote_currency in entry.meta:
                fixed_asset = validate_open(entry)
                if isinstance(fixed_asset, list):
                    for e in cast(list[PluginError], fixed_asset):  # pyright: ignore[reportUnnecessaryCast] # pyrefly: ignore [redundant-cast]
                        errors.append(e)
                else:
                    accounts[fixed_asset.account] = fixed_asset

    # Validate, and get the initial cost basis.
    for entry in entries:
        if isinstance(entry, data.Transaction) and TAG not in entry.tags:
            for posting in entry.postings:
                if posting.account in accounts:
                    fixed_asset = accounts[posting.account]
                    if (
                        posting.units is not None
                        and posting.units.currency == fixed_asset.base_currency
                    ):
                        if posting.units.number is None:
                            errors.append(
                                PluginError(
                                    source=posting.meta or entry.meta,
                                    message="The number of the units of the posting must not be None",
                                    entry=entry,
                                )
                            )

                        if posting.units.number != Decimal(
                            "1"
                        ) and posting.units.number != Decimal("-1"):
                            errors.append(
                                PluginError(
                                    source=posting.meta or entry.meta,
                                    message="The position of a fixed asset must either be 1 or -1",
                                    entry=entry,
                                )
                            )

                        if (
                            posting.units.number == Decimal("1")
                            and len(fixed_asset.cost_basis) == 0
                        ):
                            assert posting.cost is not None
                            assert isinstance(posting.cost, Cost)
                            fixed_asset.cost_basis.append(posting.cost)

    for entry in entries:
        if isinstance(entry, data.Transaction) and TAG not in entry.tags:
            for posting in entry.postings:
                if posting.account in accounts:
                    fixed_asset = accounts[posting.account]
                    if (
                        posting.units is not None
                        and posting.units.number is not None
                        and posting.units.currency == fixed_asset.quote_currency
                    ):
                        assert len(fixed_asset.cost_basis) > 0
                        last_cost_basis = fixed_asset.cost_basis[-1]
                        new_cost_basis = Cost(
                            number=last_cost_basis.number + posting.units.number,
                            currency=last_cost_basis.currency,
                            date=entry.date,
                            label=None,
                        )
                        fixed_asset.cost_basis.append(new_cost_basis)

                        entries.append(
                            data.Transaction(
                                meta=data.new_metadata("", 0),
                                date=entry.date,
                                flag="*",
                                payee=None,
                                narration=f"Adjust cost basis of {posting.account} by {posting.units}",
                                tags=entry.tags | frozenset({TAG}),
                                links=entry.links,
                                postings=[
                                    data.Posting(
                                        account=posting.account,
                                        units=Amount(
                                            number=Decimal("-1"),
                                            currency=fixed_asset.base_currency,
                                        ),
                                        cost=last_cost_basis,
                                        price=None,
                                        flag=None,
                                        meta=None,
                                    ),
                                    data.Posting(
                                        account=posting.account,
                                        units=Amount(
                                            number=-posting.units.number,
                                            currency=fixed_asset.quote_currency,
                                        ),
                                        cost=None,
                                        price=None,
                                        flag=None,
                                        meta=data.new_metadata(
                                            "",
                                            0,
                                            {
                                                "is_cash_flow": True,
                                            },
                                        ),
                                    ),
                                    data.Posting(
                                        account=posting.account,
                                        units=Amount(
                                            number=Decimal("1"),
                                            currency=fixed_asset.base_currency,
                                        ),
                                        cost=new_cost_basis,
                                        price=None,
                                        flag=None,
                                        meta=None,
                                    ),
                                ],
                            )
                        )

    return entries, errors


__plugins__ = (plugin,)
