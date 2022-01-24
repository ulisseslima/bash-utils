#!/bin/bash
# takes input and outputs it as a single line

input=/dev/stdin

cat "$input" | tr -d '\n'

if [[ "$1" == -n ]]; then
    echo ""
fi