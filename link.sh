#!/bin/bash -e

source $(real require.sh)

linkp='/usr/bin'

file="$1"
if [ -z "$file" ]; then
	echo "$0: creates a symlink to any file in $linkp"
	echo "first arg must be file to link"
	echo "second arg is optional. if specified, changes the link name, otherwise uses original filename"
	exit 1
fi

require -f file "file to link must exist"
rfile=$(readlink -f "$file")

if [ ! -f "$rfile" ]; then
	echo "not a file: $rfile"
	exit 1
fi

link_name=$(basename "$rfile")
if [ -n "$2" ]; then
	link_name="$2"
fi

rdir=$(dirname "$rfile")

link="$linkp/$link_name"
# TODO test: this returned 1 when a pre existing link did not exist, exiting the script
broken_link_check="$(file "$link")"
if [[ -f "$link" ]]; then
	ls -la "$link"
	echo "removing previous link..."
    sudo rm "$link"
elif [[ "$(echo "$broken_link_check" | grep -c broken || true)" == 1 ]]; then
	echo "$broken_link_check"
	echo "removing broken link..."
	sudo rm "$link"
fi

echo "creating link for $rfile in $linkp as $link_name ..."

sudo chmod +x "$rfile" && sudo ln -s "$rfile" "$link"

ls -la $(which "$link_name")
