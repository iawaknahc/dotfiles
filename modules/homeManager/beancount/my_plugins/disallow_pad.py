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
        if isinstance(entry, data.Pad):
            errors.append(
                PluginError(
                    source=entry.meta,
                    message="Pad directive is disallowed. Insert a transaction with the flag `P` to pad manually.",
                    entry=entry,
                )
            )
    return entries, errors


__plugins__ = (plugin,)
