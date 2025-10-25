#!/bin/bash
# grep for a specific file pattern, recursively
# note: quoting the pattern is required

source $(real require.sh)

if [[ $# -eq 0 ]]; then
	echo "usage:"
	echo "$0 pattern string-to-search start-dir"
	exit 1
fi

fpattern="$1"
search="$2"
dstart="$3"
flags="$4"

require fpattern "file pattern"; shift
require search "pattern to search for"; shift
require dstart "start directory"; shift

grep -r${flags} --color --include=$fpattern "$search" "$dstart" "$@"
