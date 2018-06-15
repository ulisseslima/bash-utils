#!/bin/bash

tmp=tmp-unicode-escape.txt
tmp_out=out-$tmp

text="$1"
if [ ! -n "$text" ]; then
	echo "first arg must be the text to escape"
	exit 1
fi

if [[ "$text" == '-d' ]]; then
	text="$2"
	echo "$text" | ascii2uni -a U -q
else
	echo "$text" > $tmp
	native2ascii -encoding utf8 $tmp $tmp_out

	cat $tmp_out
	rm $tmp $tmp_out
fi
