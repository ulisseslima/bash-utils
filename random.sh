#!/bin/bash

f="$1"
if [ ! -f "$f" ]; then
	echo 'pops a random line from a file'
	echo 'first arg must be an existing file'
	exit 1
fi

n=$(cat "$f" | wc -l)
random=$(((RANDOM % $n) +1))
word=$(cat "$f" | head -$random | tail -1)

echo $word
