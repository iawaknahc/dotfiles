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
        if not isinstance(entry, data.Transaction):
            continue
        if entry.narration is None or entry.narration == "":
            errors.append(
                PluginError(
                    source=entry.meta,
                    message="Narration is required",
                    entry=entry,
                )
            )
    return entries, errors


__plugins__ = (plugin,)
