#!/bin/bash

f="$1"
if [ ! -f "$f" ]; then
	echo "$f is not a file"
	exit 1
fi

link=$(readlink -f "$1")
dirname "$link"
