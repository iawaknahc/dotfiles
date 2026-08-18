import json
import uuid

lowercase_uuid4 = str(uuid.uuid4()).lower()
uppercase_uuid4 = lowercase_uuid4.upper()

print(
    json.dumps(
        {
            "items": [
                {
                    "title": "UUID4 in lowercase, hold ⌘ for uppercase",
                    "type": "default",
                    "subtitle": lowercase_uuid4,
                    "arg": lowercase_uuid4,
                    "mods": {
                        "cmd": {
                            "subtitle": uppercase_uuid4,
                            "arg": uppercase_uuid4,
                        }
                    },
                }
            ]
        },
        ensure_ascii=False,
    )
)
