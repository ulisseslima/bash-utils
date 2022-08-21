#!/bin/bash
# grep for a specific file pattern, recusrsively

source $(real require.sh)

fpattern="$1"
search="$2"
dstart="$3"

require fpattern "file pattern"
require search "pattern to search for"
require dstart "start directory"

grep -r --include=$fpattern "$search" "$dstart"
