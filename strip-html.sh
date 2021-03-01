#!/bin/bash

in="${1}"
tmpin=/tmp/strip

if [[ -z "$1" ]]; then
	in=/dev/stdin
else
	echo "$1" > $tmpin
	in=$tmpin
fi

cat "$in" | sed -e 's/<[^>]*>//g'
