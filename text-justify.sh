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
  echo "$line" | fold -w 35
done < "$filename"

