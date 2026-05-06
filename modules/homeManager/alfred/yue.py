import json
import sys
from urllib.parse import quote_from_bytes


def error():
    print(
        json.dumps(
            {
                "items": [
                    {
                        "title": "Enter a Chinese character",
                        "type": "default",
                        "valid": False,
                    }
                ]
            },
            ensure_ascii=False,
        )
    )


def main():
    arg = ""
    if len(sys.argv) > 1:
        arg = sys.argv[1].strip()

    try:
        # It is not 100% correct, as we need to encode spaces as + in query parameter.
        # If the input has spaces in it, the search will not produce any useful result anyway, we do not bother to handle this case.
        url_str = f"https://humanum.arts.cuhk.edu.hk/Lexis/lexi-can/search.php?q={quote_from_bytes(arg.encode(encoding='big5'))}"
        item = {
            "title": f"Look up {arg}",
            "type": "default",
            "subtitle": url_str,
            "arg": url_str,
        }
        print(json.dumps({"items": [item]}, ensure_ascii=False))
    except UnicodeEncodeError:
        error()
        return


main()
