#!/bin/bash -e
# fill input characters with blank spaces. useful for formatting

input=/dev/stdin

cat "$input" | sed "s/./ /g"
