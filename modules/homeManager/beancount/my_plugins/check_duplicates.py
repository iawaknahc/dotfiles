import hashlib
from typing import NamedTuple, cast

from beancount import Directive, Meta, Price

BUILTIN_KEYS: frozenset[str] = frozenset(
    {
        # filename is a builtin metadata key.
        # See https://github.com/beancount/beancount/blob/v3/beancount/core/data.py#L517
        "filename",
        # lineno is a builtin metadata key.
        # See https://github.com/beancount/beancount/blob/v3/beancount/core/data.py#L517
        "lineno",
        # __tolerances__ stores the tolerances of the amount.
        # See https://github.com/beancount/beancount/blob/v3/beancount/core/interpolate.py#L214
        "__tolerances__",
        # `"__automatic__": True` means the amount of the posting is inferred.
        # See https://github.com/beancount/beancount/blob/v3/beancount/core/interpolate.py#L208
        "__automatic__",
        # `"__residual__": True` means the posting was inserted to handle rounding error.
        # See https://github.com/beancount/beancount/blob/v3/beancount/core/interpolate.py#L211
        "__residual__",
    }
)


class PluginError(NamedTuple):
    source: Meta | None
    message: str
    entry: Directive | None


def _hash_value(value: object) -> str:
    md5 = hashlib.md5()
    md5.update(str(value).encode())
    return md5.hexdigest()


def _hash_meta(meta: Meta) -> str:
    hash = hashlib.md5()
    for key in sorted(meta):
        if key in BUILTIN_KEYS:
            continue
        hash.update(f"{key}={meta[key]}".encode())
    return hash.hexdigest()


def hash_entry(entry: Directive) -> str:
    hash = hashlib.md5()
    for attr_name, attr_value in zip(entry._fields, entry):
        if attr_name == "meta" and isinstance(attr_value, dict):
            hash.update(_hash_meta(attr_value).encode())
        elif isinstance(attr_value, (list, set, frozenset)):
            # Sort elements for stability (e.g., postings order shouldn't matter
            # for comparison purposes).
            sub_hashes = cast(list[str], [])
            for element in attr_value:
                if isinstance(element, tuple):
                    sub_hashes.append(hash_entry(cast(Directive, element)))
                else:
                    sub_hashes.append(_hash_value(element))
            for sub_hash in sorted(sub_hashes):
                hash.update(sub_hash.encode())
        else:
            hash.update(str(attr_value).encode())
    return hash.hexdigest()


# This plugin structurally is similar to https://github.com/beancount/beancount/blob/master/beancount/plugins/noduplicates.py
# But it does not exclude meta.
# Instead, only the generated data in meta is excluded.
def validate_no_duplicates(
    entries: list[Directive], _unused_options_map: dict[str, None] | None
) -> tuple[list[Directive], list[PluginError]]:
    seen_hashes: dict[str, Directive] = {}
    errors: list[PluginError] = []

    for entry in entries:
        hash_ = hash_entry(entry)

        if hash_ in seen_hashes:
            if isinstance(entry, Price):
                # Allow duplicate Price entries; they are common because markets
                # may return the same price on consecutive days.
                continue
            other_entry = seen_hashes[hash_]
            errors.append(
                PluginError(
                    entry.meta,
                    "Duplicate entry: {} == {}".format(entry, other_entry),
                    entry,
                )
            )
        else:
            seen_hashes[hash_] = entry

    return entries, errors


__plugins__ = ("validate_no_duplicates",)
