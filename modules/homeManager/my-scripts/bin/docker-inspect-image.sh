#!/bin/sh

# Sometimes, you want to know how an image was built.
# This command may give you some hints.

set -eux

docker history --no-trunc --format json "$1" | jq '.Comment | fromjson'
