import json
import os
import subprocess
import sys


def main():
    numbat_expr = ""
    if len(sys.argv) > 1:
        numbat_expr = " ".join(sys.argv[1:])
    if numbat_expr != "":
        numbat_expr = f"print({numbat_expr})"

    try:
        process = subprocess.run(
            [
                os.environ["NUMBAT"],
                "-e",
                numbat_expr,
            ],
            capture_output=True,
            text=True,
            check=True,
        )
        output = process.stdout.strip()
        print(
            json.dumps(
                {
                    "items": [
                        {
                            "title": output,
                            "type": "default",
                            "arg": output,
                        }
                    ],
                }
            )
        )
    except:
        print(
            json.dumps(
                {
                    "items": [
                        {
                            "title": "Invalid Numbat expression",
                            "type": "default",
                            "valid": False,
                        }
                    ],
                }
            )
        )


main()
