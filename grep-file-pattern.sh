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

require fpattern "file pattern"
require search "pattern to search for"
require dstart "start directory"

grep -r --color --include=$fpattern "$search" "$dstart"
