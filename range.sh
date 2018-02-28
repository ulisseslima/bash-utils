#!/bin/bash

if [ ! -f "$1" ]; then
	echo "first argument bust be an existing file"
	exit 1
fi

if [ ! -n "$2" ]; then
	echo "line count:"
	wc -l "$1"

	echo "specify line range to print with arguments 2 and 3"
	exit 0
fi

awk "NR >= $2 && NR <= $3" "$1"
