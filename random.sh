#!/bin/bash
# pops a random line from a file'

in=/dev/stdin
f="${1}"
if [[ -f "$f" ]]; then
	in="$f"
fi

contents="/tmp/contents"
cat $in > $contents

n=$(cat "$contents" | wc -l)
if [[ "$n" -lt 1 ]]; then
	>&2 echo "file has no lines"
	exit 1
fi

random=$(((RANDOM % $n) +1))
word=$(cat "$contents" | head -$random | tail -1)

echo $word
