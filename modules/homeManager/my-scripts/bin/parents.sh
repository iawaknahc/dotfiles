#!/bin/sh

cur="$PWD"

while true; do
	printf "%s\n" "$cur"
	if [ "$cur" = "/" ]; then break; fi
	cur="$(dirname "$cur")"
done
