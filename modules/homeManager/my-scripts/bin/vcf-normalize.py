#!/usr/bin/env python3

# This script takes an exported .vcf file from Google Contacts or iOS Contacts app, and normalize the contents.
# Here are the normalizations:
# 1. Remove group prefix.
# 2. Ensure N only have given name and family name set, and then combine them into given name.
# 3. Set the given name of N to FN.
# 4. Remove PRODID, which is a static field included by iOS Contacts app.
# 5. Remove CATEGORIES. I never use it.
# 6. Normalize phone number to E.164 formats, and set parameters to a fixed set of values, and sort the phone numbers.
# 7. For email addresses, set the parameters to a fixed of values, and sort the email addresses.
# 8. Ensure only street and country is used in address, and set parameters to a fixed set of values, and sort the addresses.
# 9. Replace "\:" in note.
# 10. Normalize bday to YYYYMMDD or --MMDD
# 11. Derive UID from TEL or EMAIL.
#     Since phone numbers and email addresses are sorted,
#     the UID is stable as long as the phone numbers or email addresses do not change.
# 12. Sort all components according to UID.

import sys

import icu
import phonenumbers
import vobject
import vobject.base
import vobject.vcard
import whenever


def add(blank: vobject.base.Component, content_lines: list[vobject.base.VBase]):
    for content_line in content_lines:
        blank.add(content_line)


def visit_version(
    blank: vobject.base.Component, content_lines: list[vobject.base.VBase]
):
    assert len(content_lines) == 1
    assert isinstance(content_lines[0], vobject.base.ContentLine)
    assert content_lines[0].name == "VERSION"
    assert content_lines[0].value == "3.0"
    assert len(content_lines[0].params) == 0
    content_lines[0].group = None
    add(blank, content_lines)


def visit_fn(blank: vobject.base.Component, content_lines: list[vobject.base.VBase]):
    assert len(content_lines) == 1
    assert isinstance(content_lines[0], vobject.base.ContentLine)
    assert content_lines[0].name == "FN"
    assert isinstance(content_lines[0].value, str)
    assert len(content_lines[0].params) == 0
    content_lines[0].group = None
    # Normalize FN by removing leading or trailing whitespaces.
    content_lines[0].value = content_lines[0].value.strip()
    # FN should not be empty after normalization.
    assert content_lines[0].value != ""
    add(blank, content_lines)


def visit_n(
    blank: vobject.base.Component, content_lines: list[vobject.base.VBase]
) -> vobject.vcard.Name:
    assert len(content_lines) == 1
    assert isinstance(content_lines[0], vobject.base.ContentLine)
    assert content_lines[0].name == "N"
    assert isinstance(content_lines[0].value, vobject.vcard.Name)
    assert len(content_lines[0].params) == 0
    content_lines[0].group = None

    # My convention is to use given name only.
    assert content_lines[0].value.prefix == ""
    assert content_lines[0].value.suffix == ""
    assert content_lines[0].value.additional == ""

    # Combine them
    if content_lines[0].value.given != "" and content_lines[0].value.family != "":
        content_lines[
            0
        ].value.given = (
            f"{content_lines[0].value.given} {content_lines[0].value.family}"
        )
        content_lines[0].value.family = ""

    # Swap them
    if content_lines[0].value.family != "" and content_lines[0].value.given == "":
        content_lines[0].value.given, content_lines[0].value.family = (
            content_lines[0].value.family,
            content_lines[0].value.given,
        )

    add(blank, content_lines)
    return content_lines[0].value


def visit_prodid(
    _blank: vobject.base.Component, content_lines: list[vobject.base.VBase]
):
    # This was observed in an export produced by iOS Contacts app.
    assert len(content_lines) == 1
    assert isinstance(content_lines[0], vobject.base.ContentLine)
    assert content_lines[0].name == "PRODID"
    assert isinstance(content_lines[0].value, str)
    # It looks like "-//Apple Inc.//iPhone OS 26.5.2//EN"
    assert content_lines[0].value.startswith("-//Apple Inc.//")
    assert len(content_lines[0].params) == 0
    content_lines[0].group = None
    # Drop it.


def visit_categories(
    _blank: vobject.base.Component, content_lines: list[vobject.base.VBase]
):
    # This was observed in an export produced by Google Contacts.
    assert len(content_lines) == 1
    assert isinstance(content_lines[0], vobject.base.ContentLine)
    assert content_lines[0].name == "CATEGORIES"
    assert isinstance(content_lines[0].value, list)
    assert len(content_lines[0].value) == 1
    assert isinstance(content_lines[0].value[0], str)
    assert content_lines[0].value[0] == "myContacts"
    assert len(content_lines[0].params) == 0
    content_lines[0].group = None
    # Drop it


def visit_tel(
    blank: vobject.base.Component, content_lines: list[vobject.base.VBase]
) -> vobject.base.ContentLine:
    # Must have phone number.
    assert len(content_lines) >= 1
    for content_line in content_lines:
        assert isinstance(content_line, vobject.base.ContentLine)
        assert content_line.name == "TEL"
        assert isinstance(content_line.value, str)
        content_line.group = None

        # Match iOS preference to include VOICE.
        # iOS may store "pref" for the preferred number, remove it.
        match content_line.params:
            case {"TYPE": ["CELL", "VOICE", "pref"]}:
                content_line.params = {"TYPE": ["CELL", "VOICE"]}
            case {"TYPE": ["CELL", "VOICE"]}:
                content_line.params = {"TYPE": ["CELL", "VOICE"]}
            case {"TYPE": ["CELL"]}:
                content_line.params = {"TYPE": ["CELL", "VOICE"]}
            case {"TYPE": ["HOME", "VOICE", "pref"]}:
                content_line.params = {"TYPE": ["HOME", "VOICE"]}
            case {"TYPE": ["HOME", "VOICE"]}:
                content_line.params = {"TYPE": ["HOME", "VOICE"]}
            case {"TYPE": ["HOME"]}:
                content_line.params = {"TYPE": ["HOME", "VOICE"]}
            case {"TYPE": ["WORK", "VOICE", "pref"]}:
                content_line.params = {"TYPE": ["WORK", "VOICE"]}
            case {"TYPE": ["WORK", "VOICE"]}:
                content_line.params = {"TYPE": ["WORK", "VOICE"]}
            case {"TYPE": ["WORK"]}:
                content_line.params = {"TYPE": ["WORK", "VOICE"]}
            case {"TYPE": ["pref"]}:
                content_line.params = {"TYPE": ["CELL", "VOICE"]}
            case {}:
                content_line.params = {"TYPE": ["CELL", "VOICE"]}
            case _:
                raise ValueError(f"unknown tel params: {content_line}")

        # Normalize the phone number to E.164 format
        try:
            phone_number = phonenumbers.parse(content_line.value)
        except phonenumbers.NumberParseException as e:
            # The original phone number is missing country calling code.
            # Apply heuristic and parse again.
            if e.error_type == phonenumbers.NumberParseException.INVALID_COUNTRY_CODE:
                phone_number = phonenumbers.parse(content_line.value, region="HK")
            else:
                # Re-raise other cases.
                raise
        content_line.value = phonenumbers.format_number(
            phone_number, phonenumbers.PhoneNumberFormat.E164
        )

    # Sort phone numbers, and then report the first one as UID.
    content_lines = sorted(content_lines, key=lambda content_line: content_line.value)
    add(blank, content_lines)
    assert isinstance(content_lines[0], vobject.base.ContentLine)
    uid_value = f"tel:{content_lines[0].value}"
    return vobject.base.ContentLine(name="UID", params={}, value=uid_value)


def visit_email(blank: vobject.base.Component, content_lines: list[vobject.base.VBase]):
    # No length restriction because I do not know the email address of all people I know.
    for content_line in content_lines:
        assert isinstance(content_line, vobject.base.ContentLine)
        assert content_line.name == "EMAIL"
        assert isinstance(content_line.value, str)
        content_line.group = None

        match content_line.params:
            case {"TYPE": ["INTERNET", "HOME"]}:
                content_line.params = {"TYPE": ["INTERNET", "HOME"]}
            case {"TYPE": ["INTERNET"]}:
                content_line.params = {"TYPE": ["INTERNET", "HOME"]}
            case {}:
                content_line.params = {"TYPE": ["INTERNET", "HOME"]}
            case _:
                raise ValueError(f"unknown email params: {content_line}")

    # Sort email addresses, and then report the first one as UID.
    content_lines = sorted(content_lines, key=lambda content_line: content_line.value)
    add(blank, content_lines)
    assert isinstance(content_lines[0], vobject.base.ContentLine)
    uid_value = f"mailto:{content_lines[0].value}"
    return vobject.base.ContentLine(name="UID", params={}, value=uid_value)


def visit_address(
    blank: vobject.base.Component, content_lines: list[vobject.base.VBase]
):
    # No length restriction because I do not know the address of all people I know.
    for content_line in content_lines:
        assert isinstance(content_line, vobject.base.ContentLine)
        assert content_line.name == "ADR"
        assert isinstance(content_line.value, vobject.vcard.Address)
        content_line.group = None

        match content_line.params:
            case {"TYPE": ["HOME"]}:
                content_line.params = {"TYPE": ["HOME"]}
            case {}:
                content_line.params = {"TYPE": ["HOME"]}
            case _:
                raise ValueError(f"unknown adr params: {content_line}")

        # I only use country and street and country.
        assert content_line.value.box == ""
        assert content_line.value.city == ""
        assert content_line.value.code == ""
        assert content_line.value.extended == ""
        assert content_line.value.region == ""
        assert content_line.value.country != ""
        assert content_line.value.street != ""

        # country should be alpha-2
        # Patch "Hong Kong" to "HK"
        if content_line.value.country == "Hong Kong":
            content_line.value.country = "HK"

        # pyrefly: ignore [missing-attribute]
        assert content_line.value.country in icu.Locale.getISOCountries()  # ty:ignore[unresolved-attribute]

    # Sort addresses.
    content_lines = sorted(
        content_lines, key=lambda content_line: str(content_line.value)
    )
    add(blank, content_lines)


def visit_note(blank: vobject.base.Component, content_lines: list[vobject.base.VBase]):
    # It does not make sense to have more than one note.
    assert len(content_lines) == 1
    assert isinstance(content_lines[0], vobject.base.ContentLine)
    assert content_lines[0].name == "NOTE"
    assert isinstance(content_lines[0].value, str)
    content_lines[0].group = None
    # It was observed that Google Contacts put a backslash before colon in note.
    # It is unnecessary, so normalize it.
    content_lines[0].value = content_lines[0].value.replace("\\:", ":")
    add(blank, content_lines)


def whenever_month_day_to_bday(month_day: whenever.MonthDay) -> str:
    # `month_day.format_iso` returns `--MM-DD` while vCard expects `--MMDD`.
    return f"--{month_day.month:02d}{month_day.day:02d}"


def visit_bday(blank: vobject.base.Component, content_lines: list[vobject.base.VBase]):
    # On 2026-08-03, it was observed that if bday is `--MMDD`, then
    # it is silently dropped by iOS Contacts app while the source (Google Calendar) supports it.

    # It does not make sense to have more than one birthday
    assert len(content_lines) == 1
    assert isinstance(content_lines[0], vobject.base.ContentLine)
    assert content_lines[0].name == "BDAY"
    assert isinstance(content_lines[0].value, str)
    content_lines[0].group = None

    match content_lines[0].params:
        case {"X-APPLE-OMIT-YEAR": ["1604"]}:
            date = whenever.Date.parse_iso(content_lines[0].value)
            month_day = whenever.MonthDay(month=date.month, day=date.day)
            content_lines[0].params = {}
            content_lines[0].value = whenever_month_day_to_bday(month_day)
        case {}:
            try:
                date = whenever.Date.parse_iso(content_lines[0].value)
                content_lines[0].value = date.format_iso(basic=True)
            except ValueError:
                # No need to try this, just let whenever to raise.
                month_day = whenever.MonthDay.parse_iso(content_lines[0].value)
                content_lines[0].value = whenever_month_day_to_bday(month_day)
        case _:
            raise ValueError(f"unknown bday params: {content_lines[0]}")

    add(blank, content_lines)


def main():
    components = []
    with open(sys.argv[1]) as f:
        gen = vobject.readComponents(
            f, validate=True, transform=True, ignoreUnreadable=False, allowQP=False
        )
        for original in gen:
            uid_phone_number = None
            uid_email = None
            n = None
            blank = vobject.vCard()
            for key, content_lines in original.contents.items():
                match key:
                    case "version":
                        visit_version(blank, content_lines)
                    case "fn":
                        visit_fn(blank, content_lines)
                    case "n":
                        n = visit_n(blank, content_lines)
                    case "prodid":
                        visit_prodid(blank, content_lines)
                    case "categories":
                        visit_categories(blank, content_lines)
                    case "tel":
                        uid_phone_number = visit_tel(blank, content_lines)
                    case "email":
                        uid_email = visit_email(blank, content_lines)
                    case "adr":
                        visit_address(blank, content_lines)
                    case "note":
                        visit_note(blank, content_lines)
                    case "bday":
                        visit_bday(blank, content_lines)
                    case "url" | "impp" | "x-ablabel" | "org" | "photo":
                        # These are ignored.
                        pass
                    case _:
                        raise ValueError(f"unknown attribute: {key}")

            # Set a deterministic UID
            if uid_phone_number is not None:
                blank.add(uid_phone_number)
            elif uid_email is not None:
                blank.add(uid_email)
            else:
                raise ValueError(f"{original} has no phone number nor email")

            # Set FN if N is found.
            if n is not None:
                fn_value = str(n).strip()
                blank.contents["fn"] = [
                    vobject.base.ContentLine(name="FN", params={}, value=fn_value)
                ]

            components.append(blank)
    components = sorted(
        components, key=lambda component: component.getChildValue("uid")
    )
    for component in components:
        print(component.serialize(), end="")


main()
