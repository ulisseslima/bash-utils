#!/bin/bash
# gets the lines from stdin matching the lexical range passed

source $(real require.sh)

read -r input

range_a="$1"
require range_a

range_b="$2"
require range_b

echo "$input" | awk "\$0 >= \"$range_a\" && \$0 <= \"$range_b\""
