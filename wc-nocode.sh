#!/bin/bash
# word count, excluding code

source $(real require.sh)

file="$1"
require file

ftmp="/tmp/$(basename $file).nocode"

total="$(cat "$file" | wc -w)"
>&2 echo "$file: $total"

cat "$file" | egrep '^[^ ]' | egrep '^[^@]' | egrep '^[^\}]' | egrep '^[^\)]' | egrep '^[^public]' | grep -v '\\$' | grep -v '{$' | grep -v ';$' > "$ftmp"

nocode="$(cat "$ftmp" | wc -w)"
>&2 echo "${ftmp}:"
echo "$nocode"

code=$((total-nocode))

>&2 echo "code: $(cross-multiply.sh $total 100 $code x)%"
