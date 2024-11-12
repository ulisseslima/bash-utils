#!/bin/bash
# pops a random line from a file
# optionally filters before popping

in=/dev/stdin
f="${1}"
if [[ -f "$f" ]]; then
	in="$f"
fi

filter="$1"
field=$2
separator=${3:-,}

contents="/tmp/contents"
if [[ -n "$filter" ]]; then
	cat $in | grep "$filter" > $contents
else
	cat $in > $contents
fi

n=$(cat "$contents" | wc -l)
if [[ "$n" -lt 1 ]]; then
	>&2 echo "file has no lines"
	exit 1
fi

random=$(((RANDOM % $n) +1))
word=$(cat "$contents" | head -$random | tail -1)

if [[ -n "$field" ]]; then
	echo "$word" | cut -d"${separator}" -f${field}
else
	echo $word
fi
