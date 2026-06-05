from typing import NamedTuple

from beancount.core import data


class PluginError(NamedTuple):
    source: data.Meta
    message: str
    entry: data.Directive | None


def plugin(
    entries: list[data.Directive],
    _unused_options: dict[str, None] | None,
    _config_str: str | None = None,
) -> tuple[list[data.Directive], list[PluginError]]:
    errors: list[PluginError] = []

    # First, see what account has opted in this plugin.
    account_narration: dict[data.Account, str] = {}
    for entry in entries:
        if isinstance(entry, data.Open):
            if "auto_narration" in entry.meta:
                value = entry.meta["auto_narration"]  # pyright: ignore[reportAny]
                if not isinstance(value, str):
                    errors.append(
                        PluginError(
                            source=entry.meta,
                            message="The value of `auto_narration` must be a string. It is the narration.",
                            entry=entry,
                        )
                    )
                else:
                    account_narration[entry.account] = entry.meta["auto_narration"]

    # Then, we add narrations.
    for idx, entry in enumerate(entries):
        if isinstance(entry, data.Transaction):
            # This plugin only adds narration for simple transactions
            # 1. The transaction has no narration.
            # 2. The transaction has exactly 2 postings.
            # 3. Exactly one of the postings is from the opted in account.
            if entry.narration is not None and entry.narration != "":  # Condition 1
                continue
            if len(entry.postings) != 2:  # Condition 2
                continue

            opted_in_accounts: set[data.Account] = set()
            for posting in entry.postings:
                if posting.account in account_narration:
                    opted_in_accounts.add(posting.account)

            if len(opted_in_accounts) != 1:  # Condition 3
                continue

            # If we reach here, the transaction is subject to auto narration.
            account = next(iter(opted_in_accounts))
            narration = account_narration[account]
            new_entry = entry._replace(narration=narration)
            entries[idx] = new_entry

    return entries, errors


__plugins__ = (plugin,)
