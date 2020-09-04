#!/bin/bash

linkp=/usr/local/bin

file="$1"
if [ ! -n "$file" ]; then
	echo "$0: creates a symlink to any file in $linkp"
	echo "first arg must be file to link"
	echo "second arg is optional. if specified, changes the link name, otherwise uses original filename"
	exit 1
fi

rfile=$(readlink -f "$file")

if [ ! -f "$rfile" ]; then
	echo "not a file: $rfile"
	exit 1
fi

echo "creating link for $rfile in $linkp..."

link_name=$(basename "$rfile")
if [ -n "$2" ]; then
	link_name="$2"
fi

rdir=$(dirname "$rfile")

link="$linkp/$link_name"
if [ -f "$link" ]; then
	echo "removing previous link..."
        sudo rm "$link"
fi

chmod +x "$rfile" && sudo ln -s "$rfile" "$link"

ls -la $(which "$link_name")
