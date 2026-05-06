#!/bin/sh

find ~/.local/share/direnv/ -type f -exec sh -c 'printf "%s -> %s\n" $1 "$(cat $1)"' _ {} \;
