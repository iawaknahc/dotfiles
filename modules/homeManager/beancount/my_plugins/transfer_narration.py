from decimal import Decimal
from typing import Literal, NamedTuple

from beancount.core import data
from beancount.core.amount import Amount


class PluginError(NamedTuple):
    source: data.Meta
    message: str
    entry: data.Directive | None


AccountType = Literal["assets"] | Literal["liabilities"]

ZERO = Decimal("0")


def is_assets(s: str) -> bool:
    return s.startswith("Assets:")


def is_liabilities(s: str) -> bool:
    return s.startswith("Liabilities:")


def account_type(s: str) -> AccountType | None:
    if is_assets(s):
        return "assets"
    if is_liabilities(s):
        return "liabilities"
    return None


def is_assets_or_liabilities(s: str) -> bool:
    return is_assets(s) or is_liabilities(s)


def derive_narration(entry: data.Transaction) -> str | None:
    # No need to derive narration is the transaction has a narration already.
    if entry.narration is not None and entry.narration != "":
        return None

    # We can only handle transactions with exactly 2 postings.
    if len(entry.postings) != 2:
        return None

    positive_amount: Amount | None = None
    positive_number_account_type: AccountType | None = None
    negative_number_account_type: AccountType | None = None
    for posting in entry.postings:
        # We can only handle transactions involving Assets and Liabilities.
        if not is_assets_or_liabilities(posting.account):
            return None

        # We can only handle transactions without cost and price
        if posting.cost is not None or posting.price is not None:
            return None

        # We can only handle postings with non-zero amount
        if posting.units is None:
            return None
        if posting.units.number is None:
            return None
        if posting.units.number > ZERO:
            positive_amount = posting.units
            positive_number_account_type = account_type(posting.account)
        elif posting.units.number < ZERO:
            negative_number_account_type = account_type(posting.account)

    if (
        positive_amount is None
        or positive_number_account_type is None
        or negative_number_account_type is None
    ):
        return None

    match (positive_number_account_type, negative_number_account_type):
        case ("assets", "assets"):
            return f"Transfer {positive_amount}"
        case ("assets", "liabilities"):
            return f"Pop up {positive_amount}"
        case ("liabilities", "assets"):
            return f"Repay {positive_amount}"
        case ("liabilities", "liabilities"):
            # No idea how to deal with this.
            return None


def plugin(
    entries: list[data.Directive],
    _unused_options: dict[str, None] | None,
    _config_str: str | None = None,
) -> tuple[list[data.Directive], list[PluginError]]:
    errors: list[PluginError] = []

    for idx, entry in enumerate(entries):
        if not isinstance(entry, data.Transaction):
            continue
        if entry.narration is not None and entry.narration != "":
            continue
        narration = derive_narration(entry)
        if narration is None:
            continue
        new_tags = entry.tags | {"transfer"}
        entries[idx] = entry._replace(narration=narration, tags=new_tags)

    return entries, errors


__plugins__ = (plugin,)
