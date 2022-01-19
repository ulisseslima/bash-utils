#!/bin/bash
# word frequency in a text file
# https://stackoverflow.com/questions/10552803/how-to-create-a-frequency-list-of-every-word-in-a-file/10573100

source $(real require.sh)

file="$1"
require -f file "text file to check"

sed -e  's/[^A-Za-z]/ /g' "$file" | tr 'A-Z' 'a-z' | tr ' ' '\n' | grep -v '^$'| sort | uniq -c | sort -rn
