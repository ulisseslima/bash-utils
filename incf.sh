#!/bin/bash
# increments a number in a file

f="$1"
n=0

if [ -f "$f" ]; then
	n=$(cat $f)
else
	echo $n > $f
fi

((n++))

echo $n > $f && echo $n
