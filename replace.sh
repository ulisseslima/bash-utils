#!/bin/bash -e

source $(real require.sh)

input=/dev/stdin

search="$1"
replace="$2"

require search 'string to search for'
require replace 'replacement string'

cat "$input" | sed "s/$search/$replace/g"
