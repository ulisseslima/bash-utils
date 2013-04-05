#!/bin/bash -e

if [ "$1" == "--help" ]; then
  echo "switches between two files that have the same purpose."
  echo "e.g."
  echo "$0 path/to/file"
  echo ""
  echo "when used for the first time, will create a copy of the file to be eventually toggled"
  echo "when used on subsequent times, it will switch the file by its copy"
  echo ""
  echo "you can pass a program to call the file with (after switching) like this:"
  echo "$0 path/to/file nano"
fi

file="$1"
app=$2
disabling="disabling"
disabled="disabled"

mv "$file" "$file".$disabling
if [ -f "$file".$disabled ]; then
  mv "$file".$disabled "$file"
else
  cp "$file".$disabling "$file"	
fi
mv "$file".$disabling "$file".$disabled

if [[ -n $app ]]; then
  $app "$file"
fi
