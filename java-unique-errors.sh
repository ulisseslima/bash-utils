#!/bin/bash
# creates a file containing only unique errors from a log4j log file

f="$1"
if [[ ! -f "$f" ]]; then
	echo "arg 1 must be an existing file"
	exit 1
fi

result="unique.err"

grep ERROR $f | cut -d' ' -f4- | sort -u > $result
readlink -f "$result"
