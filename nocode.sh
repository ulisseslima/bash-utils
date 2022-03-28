#!/bin/bash
# word count, excluding code

source $(real require.sh)

file="$1"
require file

cat "$file" | egrep '^[^ ]' | egrep '^[^@]' | egrep '^[^\}]' | egrep '^[^\)]' | egrep '^[^public]' | grep -v '\\$' | grep -v '{$' | grep -v ';$' | grep -v '^<'
