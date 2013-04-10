#!/bin/bash

if [ "$1" == '--help' ]; then
  echo "deletes all lines in a file matching the pattern"
fi

pat="$1"
file="$2"

sed -i "/$pat/d" "$file"
