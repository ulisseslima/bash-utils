#!/bin/bash
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

# Check if an input file is provided
if [[ ! -f "$1" ]]; then
  echo "Usage: $ME [input_file]"
  exit 1
fi

max_characters_per_line=${2:-22}
>&2 echo "$ME - page width: $max_characters_per_line"

# Read input file and wrap lines
while read -r line; do
  while [[ ${#line} -gt $max_characters_per_line ]]; do
    # Find the last space character within the first $max_characters_per_line characters of the line
    wrap_index=$(echo "${line:0:$max_characters_per_line}" | sed -n 's/[^ ]* *$//p' | wc -c)
    wrap_index=$((wrap_index-1))
    if [[ $wrap_index == 0 ]]; then
      # no spaces (word too long) or space too late
      echo "${line:0:$max_characters_per_line}-"
      line="${line:$max_characters_per_line}"
    else
      # Output the first part of the line (up to the wrap index)
      echo "${line:0:$wrap_index}"
      # Remove the first part of the line (up to the wrap index)
      line="${line:$wrap_index}"
    fi
  done
  # Output any remaining characters on the line (less than $max_characters_per_line characters)
  echo "$line"
done < "$1"
