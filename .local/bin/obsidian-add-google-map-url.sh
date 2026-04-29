#!/bin/sh

set -eu

. ~/.config/sops-nix/secrets/rendered/obsidian-google-places-api-key.sh

u="$(google-map-url-resolve.py "$1")"
details_json="$(google-places-api-details.py "$u")"
name="$(printf "%s\n" "$details_json" | jq '.name' -r)"
content="$(printf "%s\n" "$details_json" | jq 'del(.name)' | kyamlfmt -)"
content="$(printf "%s\n%s\n" "$content" "---")"
obsidian create "name=$name" "content=$content\n" open newtab
