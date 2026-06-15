from typing import NamedTuple

from beancount import Directive, Meta
from beancount.core import data


class PluginError(NamedTuple):
    source: Meta
    message: str
    entry: Directive | None


def _check_directive_meta(
    meta: Meta,
    narration_keys: set[str],
    entry: Directive,
    errors: list[PluginError],
) -> None:
    for key, value in meta.items():
        if key not in narration_keys:
            continue
        if isinstance(entry, data.Transaction):
            errors.append(
                PluginError(
                    source=meta,
                    message=f'"{key}" should not be used on a transaction. Describe the transaction with the narration.',
                    entry=entry,
                )
            )
        else:
            if not isinstance(value, str) or not value.strip():
                errors.append(
                    PluginError(
                        source=meta,
                        message=f'"{key}" must be a non-empty string, got {repr(value)}',
                        entry=entry,
                    )
                )


def _check_posting_meta(
    meta: Meta,
    narration_keys: set[str],
    entry: Directive,
    errors: list[PluginError],
) -> None:
    for key, value in meta.items():
        if key not in narration_keys:
            continue
        if not isinstance(value, str) or not value.strip():
            errors.append(
                PluginError(
                    source=meta,
                    message=f'"{key}" must be a non-empty string, got {repr(value)}',
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

    narration_keys: set[str] = set(config_str.split(" "))

    for entry in entries:
        _check_directive_meta(entry.meta, narration_keys, entry, errors)
        if isinstance(entry, data.Transaction):
            for posting in entry.postings:
                if posting.meta is not None:
                    _check_posting_meta(posting.meta, narration_keys, entry, errors)

    return entries, errors


__plugins__ = (plugin,)
