#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <filename>"
  exit 1
fi

filename="$1"

if [ ! -f "$filename" ]; then
  echo "Error: file '$filename' not found"
  exit 1
fi

while IFS= read -r line; do
  echo "$line" | awk '{ for (i=1; i<=NF; i++) { printf "%s ", $i; if (i % 7 == 0) printf "\n" } }'
done < "$filename"
