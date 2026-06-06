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

    for entry in entries:
        if isinstance(entry, data.Transaction):
            for posting in entry.postings:
                if posting.meta is not None:
                    if "__automatic__" in posting.meta:
                        errors.append(
                            PluginError(
                                source=posting.meta,
                                message="All postings must have explicit amounts.",
                                entry=entry,
                            )
                        )

    return entries, errors


__plugins__ = (plugin,)
