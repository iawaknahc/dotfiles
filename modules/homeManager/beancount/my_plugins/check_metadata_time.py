import re
from typing import NamedTuple

from beancount import Directive, Meta
from beancount.core import data

TIME_RE = re.compile(r"^([01]\d|2[0-3]):[0-5]\d$")


class PluginError(NamedTuple):
    source: Meta
    message: str
    entry: Directive | None


def _check_meta(
    meta: Meta,
    time_keys: set[str],
    entry: Directive,
    errors: list[PluginError],
) -> None:
    for key, value in meta.items():  # pyright: ignore[reportAny]
        if key not in time_keys:
            continue
        if not isinstance(value, str) or not TIME_RE.match(value):
            errors.append(
                PluginError(
                    source=meta,
                    message=f'"{key}" must be a time in format `HH:MM`, got {repr(value)}',
                    entry=entry,
                )
            )


def plugin(
    entries: list[Directive],
    _unused_options: dict[str, None] | None,
    config_str: str | None = None,
) -> tuple[list[Directive], list[PluginError]]:
    errors: list[PluginError] = []

    if not config_str:
        return entries, errors

    time_keys: set[str] = set(config_str.split(" "))

    for entry in entries:
        _check_meta(entry.meta, time_keys, entry, errors)
        if isinstance(entry, data.Transaction):
            for posting in entry.postings:
                if posting.meta is not None:
                    _check_meta(posting.meta, time_keys, entry, errors)

    return entries, errors


__plugins__ = (plugin,)
