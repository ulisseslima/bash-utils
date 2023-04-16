#!/bin/bash

source $(real require.sh)

max_len=$1
require max_len

input="$(cat /dev/stdin)"
in_size=$(echo "$input" | wc -c)

if [[ $in_size -gt $max_len ]]; then
	echo "${input:0:$max_len}"
else
	echo "$input"
fi
