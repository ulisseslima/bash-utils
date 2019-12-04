#!/bin/bash

in=/dev/stdin
if [[ -n "$1" ]]; then
	in=$(real "$1")
fi

cat $in | xclip -sel clip
