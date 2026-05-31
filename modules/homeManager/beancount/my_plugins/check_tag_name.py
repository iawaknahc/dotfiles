import re
from typing import NamedTuple

from beancount.core.data import Directive, Meta, Transaction

REGULAR_EXPRESSION = re.compile(r"^[a-zA-Z][-a-zA-Z0-9]*[a-zA-Z0-9]$|^[a-zA-Z]$")


class PluginError(NamedTuple):
    source: Meta
    message: str
    entry: Directive | None


def plugin(
    entries: list[Directive],
    _unused_options: dict[str, None] | None,
    _config_str: str | None = None,
) -> tuple[list[Directive], list[PluginError]]:
    errors: list[PluginError] = []
    for entry in entries:
        if not isinstance(entry, Transaction):
            continue
        for tag in entry.tags:
            if not REGULAR_EXPRESSION.match(tag):
                errors.append(
                    PluginError(
                        source=entry.meta,
                        message=f"#{tag} does not match the regular expression {repr(REGULAR_EXPRESSION)}",
                        entry=entry,
                    )
                )
    return entries, errors


__plugins__ = (plugin,)
