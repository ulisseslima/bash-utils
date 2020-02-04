#!/bin/bash

in=/dev/stdin
if [[ -n "$1" ]]; then
	in=$(real "$1")
fi

printf "$(cat $in)" | xclip -sel clip
