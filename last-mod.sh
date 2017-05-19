#!/bin/bash

file="$1"
if [ ! -n "$file" ]; then
	echo "gives a time difference (in seconds) between the moment the command was run and the file was modified"
	echo ""
	echo "usage:"
	echo "$0 /path/to/file"
	exit 1
fi

echo $(($(date +%s) - $(stat -c %Y -- "$file")))
